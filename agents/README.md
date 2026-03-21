# agents

This directory is a reusable home for agent-related files that can be shared across projects.

The intended use is to symlink or copy files from here into different agent config directories,
skill folders, or other agent runtimes. Treat it as a portable source of truth for important agent
behavior and supporting materials.

It is intended to be a personal collection similar in spirit to
[`github/awesome-copilot`](https://github.com/github/awesome-copilot), but maintained for my own
agents, workflows, and preferences.

## Use Cases

- shared agent rules
- reusable prompts
- skill definitions
- agent templates
- instruction packs
- workflow notes
- setup helpers
- environment preparation docs

## Current Files

- `AGENTS.md`: baseline rules and operating constraints for agents.
- `install-rules.py`: symlinks `AGENTS.md` into supported agent config directories.
- `install-cli.sh`: command snippets for installing/updating common agent CLIs.
- `install-skills.sh`: command snippets for listing/installing/updating shared skills.

## Guidelines

- Keep files portable across repositories when possible.
- Prefer plain text and small reviewable files.
- Document assumptions that downstream agent setups need to know.
- Keep secrets and machine-specific credentials out of this directory.
- Prefer reusable materials that can be copied, symlinked, or adapted by multiple agents.

## Distribution

You can:

- symlink files from this directory into an agent's config or skills folder
- copy selected files into another agent environment
- treat this directory as the canonical source and sync outward from it

## Utilities

### Install shared baseline rules

`install-rules.py` currently targets:

- Codex: `AGENTS.md` -> `${CODEX_HOME:-~/.codex}/AGENTS.md`
- OpenCode: `AGENTS.md` -> `${XDG_CONFIG_HOME:-~/.config}/opencode/AGENTS.md`
- Claude Code: `AGENTS.md` -> `~/.claude/CLAUDE.md`
- Gemini: `AGENTS.md` -> `~/.gemini/GEMINI.md`

Run:

```bash
python3 agents/install-rules.py
```

Notes:

- each target is handled independently
- missing target directories are skipped
- existing target file/symlink is replaced with a symlink to this repo copy

### Install or update agent CLIs

`install-cli.sh` is a command list (review before running):

```bash
bash agents/install-cli.sh
```

### Install or update shared skills

`install-skills.sh` is a command list for `npx skills` workflows:

```bash
bash agents/install-skills.sh
```

## Goal

Build a personal, reusable library of agent resources that is easy to share across environments and
easy to extend over time.
