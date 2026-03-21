#!/usr/bin/env python3

import os
import sys
from pathlib import Path


def install_one(target_dir: Path, source_file: Path, target_name: str) -> None:
    if not target_dir.exists():
        print(f"skipped  {target_dir} (not found)")
        return

    target_file = target_dir / target_name

    if target_file.exists() or target_file.is_symlink():
        target_file.unlink()

    target_file.symlink_to(source_file)
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
    gemini_dir = Path("~/.gemini").expanduser()

    install_one(codex_dir, agents_file, "AGENTS.md")
    install_one(opencode_dir, agents_file, "AGENTS.md")
    install_one(claude_dir, agents_file, "CLAUDE.md")
    install_one(gemini_dir, agents_file, "GEMINI.md")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
