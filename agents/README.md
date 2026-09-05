# agents

Reusable, symlink-first agent resources shared across projects.

This directory is the canonical source for baseline agent rules and supporting command references.
The primary workflow is to symlink files from here into each agent runtime/config location.

## What this directory contains

- `AGENTS.md`: global baseline rules for coding agents.
- `evals/global-rules.md`: behavioral scenarios for validating changes to the global rules.
- `install-rules.py`: installs the baseline by creating symlinks in supported agent config dirs.
- `install-cli.md`: curated CLI install/update command snippets.
- `install-skills.md`: curated `npx skills` command snippets.

## Core workflow

1. Maintain shared rules in `agents/AGENTS.md`.
2. Configure permissions directly in the agent runtime; auto-approval is generally used.
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
- Generic cross-tool (read by Kimi Code): `AGENTS.md` -> `~/.agents/AGENTS.md`

Behavior:

- Each target is handled independently.
- Missing destination directories are skipped.
- Existing regular files are preserved as `.bak` backups (numbered when a backup already exists).
- Destination links are replaced atomically; a failed link creation leaves the destination intact.

The installer links only `AGENTS.md`; it does not install permission configuration, skills, or CLIs.
The repository-root `AGENTS.md` contains guidance for this Nix configuration repository. It is not
the global rules source and is not installed by this script.

Auto-approval controls tool prompting. The global rules still define task authorization, safety, and
secret handling.

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
