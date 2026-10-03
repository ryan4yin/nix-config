"""Report deployed/booted NixOS kernel identity without reading kernel contents."""

import argparse
import os
import tempfile
from pathlib import Path


def render_metrics(deployed_kernel: Path, booted_kernel: Path) -> str:
    header = (
        "# HELP nixos_kernel_status_success Kernel identity comparison succeeded.\n"
        "# TYPE nixos_kernel_status_success gauge\n"
    )
    try:
        deployed = deployed_kernel.resolve(strict=True)
        booted = booted_kernel.resolve(strict=True)
        if not deployed.is_file() or not booted.is_file():
            raise OSError("Kernel image unavailable")
    except (OSError, RuntimeError):
        # Do not confuse missing boot metadata with a healthy running kernel.
        return header + "nixos_kernel_status_success 0\n"
    return (
        header
        + "nixos_kernel_status_success 1\n"
        + "# HELP nixos_kernel_reboot_required Deployed kernel differs from booted kernel.\n"
        + "# TYPE nixos_kernel_reboot_required gauge\n"
        + f"nixos_kernel_reboot_required {int(deployed != booted)}\n"
    )


def write_metrics(output: Path, metrics: str) -> None:
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=output.parent,
            prefix=".kernel-status-",
            delete=False,
        ) as handle:
            temporary = Path(handle.name)
            handle.write(metrics)
            handle.flush()
            os.fchmod(handle.fileno(), 0o644)
        os.replace(temporary, output)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    # The system profile includes boot-only deployments; /run/current-system
    # would miss a newer kernel selected for next boot but not switched live.
    parser.add_argument(
        "--deployed-kernel",
        type=Path,
        default=Path("/nix/var/nix/profiles/system/kernel"),
    )
    parser.add_argument(
        "--booted-kernel", type=Path, default=Path("/run/booted-system/kernel")
    )
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    write_metrics(args.output, render_metrics(args.deployed_kernel, args.booted_kernel))


if __name__ == "__main__":
    main()
