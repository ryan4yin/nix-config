# Agent CLI Commands

Reference commands for installing and updating agent CLIs. Run only the commands you need.

## Install CLIs

Installed via Nix:

- codex
- opencode
- kimi-code
- pi
- omp

## Optional tooling

```bash
# context7: up-to-date docs and code examples for LLMs and agents
npx ctx7 setup
```

## Update

The agent CLIs come from Nix (`home/base/gui/dev-tools.nix`) through the `llm-agents` flake input,
so update them with the flake rather than npm.
