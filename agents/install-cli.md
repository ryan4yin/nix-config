# Agent CLI Commands

Reference commands for installing and updating agent CLIs. Run only the commands you need.

## Install CLIs

Installed via Nix:

- codex
- cursor-cli
- claude-code
- gemini-cli

Install Manually:

```bash
# kimi-cli
uv tool install --python 3.13 kimi-cli
uv tool upgrade kimi-cli --no-cache
```

## Optional tooling

```bash
# context7: up-to-date docs and code examples for LLMs and agents
npx ctx7 setup
```

## Update npm-installed agent tools

```bash
npm update -g
```
