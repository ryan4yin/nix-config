# Agents

Home Manager module that owns the Nix side of the AI coding agents: deploying the global rules, the
agent CLIs, and their environment.

The canonical rules text, behavioral scenarios, and external-tool snippets live in the top-level
[`agents/`](../../../../agents/README.md) directory. That directory stays portable Markdown with no
Nix dependency; this module only wires it into place.

## Files

- `rules.nix`: links the global rules to every agent's config location.
- `packages.nix`: agent CLIs (`codex`, `opencode2`, `kimi-code`, `pi`, `omp`) and the Grafana MCP
  server, from the `llm-agents` flake input.
- `env.nix`: telemetry and auto-update opt-outs for the agents.

## Deployed rule targets

`rules.nix` creates one out-of-store symlink per target, all pointing at
`~/nix-config/agents/AGENTS.md`:

| Agent                  | Target                         |
| ---------------------- | ------------------------------ |
| Codex                  | `~/.codex/AGENTS.md`           |
| OpenCode               | `~/.config/opencode/AGENTS.md` |
| Pi                     | `~/.pi/agent/AGENTS.md`        |
| OMP                    | `~/.omp/agent/AGENTS.md`       |
| Cross-tool (Kimi Code) | `~/.agents/AGENTS.md`          |

Out-of-store means an edit to `agents/AGENTS.md` takes effect on the next agent session without a
Home Manager switch. The trade-off is that the rules stay writable in the checkout; use a store
symlink (`home.file.<target>.source = ../../../../agents/AGENTS.md`) if immutability matters more
than fast iteration.

The module is imported through `home/base/tui`, so it applies to every host that imports
`home/linux/gui.nix` or the macOS `home/darwin` stack. Core-only servers do not get it.
