#!/usr/bin/env python3

import os
import sys
import tempfile
from pathlib import Path


def install_one(target_dir: Path, source_file: Path, target_name: str) -> None:
    if not target_dir.exists():
        print(f"skipped  {target_dir} (not found)")
        return

    target_file = target_dir / target_name

    if target_file.is_file() and not target_file.is_symlink():
        # Preserve the old inode without reading its contents or replacing an earlier backup.
        index = 0
        while True:
            suffix = ".bak" if index == 0 else f".bak.{index}"
            backup = target_file.with_name(target_file.name + suffix)
            try:
                os.link(target_file, backup)
                break
            except FileExistsError:
                index += 1
        print(f"backed up  {target_file} -> {backup}")

    # Create the link on the same filesystem before atomically replacing the destination.
    with tempfile.TemporaryDirectory(prefix=".install-rules-", dir=target_dir) as staging:
        link = Path(staging) / target_name
        link.symlink_to(source_file)
        link.replace(target_file)
    print(f"linked  {target_file} -> {source_file}")


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    agents_file = script_dir / "AGENTS.md"

    if not agents_file.is_file():
        print(f"Missing source file: {agents_file}", file=sys.stderr)
        return 1

    codex_dir = Path(os.environ.get("CODEX_HOME", "~/.codex")).expanduser()
    xdg_config_home = Path(os.environ.get("XDG_CONFIG_HOME", "~/.config")).expanduser()
    opencode_dir = xdg_config_home / "opencode"
    claude_dir = Path("~/.claude").expanduser()
    agents_dir = Path("~/.agents").expanduser()
    install_one(codex_dir, agents_file, "AGENTS.md")
    install_one(opencode_dir, agents_file, "AGENTS.md")
    install_one(claude_dir, agents_file, "CLAUDE.md")
    install_one(agents_dir, agents_file, "AGENTS.md")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
