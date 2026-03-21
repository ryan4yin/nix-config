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
- `install-agents.py`: installs shared agent files into supported agent config directories.

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

## Installation

Current install targets:

- Codex: `AGENTS.md` -> `~/.codex/AGENTS.md`
- OpenCode: `AGENTS.md` -> `~/.config/opencode/AGENTS.md`
- Claude Code: `AGENTS.md` -> `~/.claude/CLAUDE.md`
- Gemini: `AGENTS.md` -> `~/.gemini/GEMINI.md`

Run:

```bash
python3 agents/install-agents.py
```

The installer handles each target independently and skips it if the destination directory does not
already exist.

## Goal

Build a personal, reusable library of agent resources that is easy to share across environments and
easy to extend over time.
