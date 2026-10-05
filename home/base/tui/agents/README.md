# Agents

Home Manager module that owns the Nix side of the AI coding agents: deploying the global rules, the
agent CLIs, and their environment.

The canonical rules text, behavioral scenarios, and external-tool snippets live in the top-level
[`agents/`](../../../../agents/README.md) directory. That directory stays portable Markdown with no
Nix dependency; this module only wires it into place.

## Files

- `rules.nix`: links the global rules to every agent's config location.
- `packages.nix`: agent CLIs (`codex`, `opencode2`, `pi`) from the `llm-agents` flake input, plus
  `pkgs.mcp-grafana` for the Grafana MCP server.
- `env.nix`: telemetry and auto-update opt-outs for the agents.
- `dsh/`: the dsh `web` profile that lives in `~/.dsh`. See [dsh/README.md](./dsh/README.md) for the
  link granularity, the tracked members and which hosts import it.

## Deployed rule targets

`rules.nix` creates one out-of-store symlink per target, all pointing at
`~/nix-config/agents/AGENTS.md`:

| Agent      | Target                         |
| ---------- | ------------------------------ |
| Codex      | `~/.codex/AGENTS.md`           |
| OpenCode   | `~/.config/opencode/AGENTS.md` |
| Pi         | `~/.pi/agent/AGENTS.md`        |
| Cross-tool | `~/.agents/AGENTS.md`          |

Out-of-store means an edit to `agents/AGENTS.md` takes effect on the next agent session without a
Home Manager switch. The trade-off is that the rules stay writable in the checkout; use a store
symlink (`home.file.<target>.source = ../../../../agents/AGENTS.md`) if immutability matters more
than fast iteration.
