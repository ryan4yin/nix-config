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

dsh is installed by this module but configured at runtime, not by Nix: profile patches live in
`~/.dsh/profiles/<name>/cordis.patch.yml`. See [dsh.md](./dsh.md) for the layer order and the
settings that bite.

## Deployed rule targets

`rules.nix` creates one out-of-store symlink per target, all pointing at
`~/nix-config/agents/AGENTS.md`:

| Agent      | Target                         |
| ---------- | ------------------------------ |
| Codex      | `~/.codex/AGENTS.md`           |
| OpenCode   | `~/.config/opencode/AGENTS.md` |
| Pi         | `~/.pi/agent/AGENTS.md`        |
| Cross-tool | `~/.agents/AGENTS.md`          |
| dsh        | `~/.dsh/AGENTS.md`             |

dsh reads both `~/.dsh/AGENTS.md` (`$DSH_HOME`) and, from `0.2.1-alpha.2` on, `~/.agents/AGENTS.md`
(`$DSH_AGENTS_HOME`); identical content renders once.

Out-of-store means an edit to `agents/AGENTS.md` takes effect on the next agent session without a
Home Manager switch. The trade-off is that the rules stay writable in the checkout; use a store
symlink (`home.file.<target>.source = ../../../../agents/AGENTS.md`) if immutability matters more
than fast iteration.
