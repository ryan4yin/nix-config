# Agent CLI Commands

Reference commands for installing and updating agent CLIs. Run only the commands you need.

## Install CLIs

Installed via Nix:

- codex
- opencode
- cursor-agent(cli)
- claude-code

## Optional tooling

```bash
# context7: up-to-date docs and code examples for LLMs and agents
npx ctx7 setup
```

rtk init:

```bash
rtk init -g # configure claude-code
rtk init -g --codex
rtk init -g --opencode
rtk init -g --agent cursor
```

## Update npm-installed agent tools

```bash
npm update -g
```
