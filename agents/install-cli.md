# Agent CLI Commands

Reference commands for installing and updating agent CLIs. Run only the commands you need.

## Install CLIs

Installed via Nix:

- codex
- opencode
- kimi-code
- pi
- omp
- crush

## Optional tooling

```bash
# context7: up-to-date docs and code examples for LLMs and agents
npx ctx7 setup
```

rtk init:

```bash
rtk init -g --codex
rtk init -g --opencode
```

## Update npm-installed agent tools

```bash
npm update -g
```
