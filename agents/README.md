# agents

Reusable, symlink-first agent resources shared across projects.

This directory is the canonical source for baseline agent rules and supporting command references.
The primary workflow is to symlink files from here into each agent runtime/config location.

## What this directory contains

- `AGENTS.md`: global baseline rules for coding agents.
- `permissions.md`: permission policies for agent tool access.
- `install-rules.py`: installs the baseline by creating symlinks in supported agent config dirs.
- `install-cli.md`: curated CLI install/update command snippets.
- `install-skills.md`: curated `npx skills` command snippets.

## Core workflow

1. Maintain shared rules in `agents/AGENTS.md`.
2. Define permission policies in `agents/permissions.md`.
3. Run `install-rules.py` to refresh symlinks in local agent homes.
4. Use `install-cli.md` and `install-skills.md` as reference snippets when needed.

## Install baseline rules (symlink-based)

Run:

```bash
python3 agents/install-rules.py
```

Current targets:

- Codex: `AGENTS.md` -> `${CODEX_HOME:-~/.codex}/AGENTS.md`
- OpenCode: `AGENTS.md` -> `${XDG_CONFIG_HOME:-~/.config}/opencode/AGENTS.md`
- Claude Code: `AGENTS.md` -> `~/.claude/CLAUDE.md`
- Gemini: `AGENTS.md` -> `~/.gemini/GEMINI.md`

Behavior:

- Each target is handled independently.
- Missing destination directories are skipped.
- Existing destination file/symlink is replaced with a symlink to this repo source file.

## About `install-cli.md` and `install-skills.md`

Use them as snippet libraries:

- review the commands
- select what you need
- run selected commands manually

## Conventions

- Keep files portable and reviewable.
- Keep secrets and machine-specific credentials out of this directory.
- Keep guidance generic enough to reuse across multiple agent environments.

## Goal

Maintain one reusable source of truth for agent setup that stays simple to sync and easy to evolve.
