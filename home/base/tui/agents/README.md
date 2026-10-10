# Agents

Home Manager module that owns the Nix side of the AI coding agents: deploying the global rules and
custom global skills, the agent CLIs, and their environment.

The canonical rules text, behavioral scenarios, and external-tool snippets live in the top-level
[`agents/`](../../../../agents/README.md) directory. That directory stays portable Markdown with no
Nix dependency; this module only wires it into place.

## Files

- `rules.nix`: links the global rules to every agent's config location.
- `skills.nix`: links individual custom global skills into `~/.agents/skills/`.
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

## Global skills

`skills.nix` links `~/nix-config/agents/skills/git-delivery` into `~/.agents/skills/git-delivery`
using the same out-of-store mechanism. Each custom skill gets an explicit link; the parent directory
and third-party skills remain unmanaged. Home Manager's normal collision checks apply: do not force
replacement of an existing same-name skill.

The installed releases support the shared root and symlinked skill directories, so no agent-specific
compatibility links are needed:

| Agent    | Discovery reference                                                                                                                                                                                                                                                                                       |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Codex    | [Skill documentation](https://learn.chatgpt.com/docs/build-skills.md) lists `~/.agents/skills` and symlinked skill folders.                                                                                                                                                                               |
| OpenCode | [v2.0.22 discovery](https://github.com/anomalyco/opencode/blob/v2.0.22/packages/core/src/config/discovery.ts) includes the global `.agents` root; its [compatibility loader](https://github.com/anomalyco/opencode/blob/v2.0.22/packages/core/src/config/plugin/compatibility.ts) follows skill symlinks. |
| Pi       | [v1.0.1 discovery](https://github.com/badlogic/pi-mono/blob/v1.0.1/packages/coding-agent/src/core/package-manager.ts) includes `~/.agents/skills` and follows symlink directories.                                                                                                                        |
| dsh      | [Filesystem skill package](https://www.npmjs.com/package/@deepseek-ai/dsh-skill-filesystem) documents `~/.agents/skills` and directory symlinks; confirmed in the shipped 0.2.0-rc.2 loader.                                                                                                              |

Adding or removing links requires a user-run Home Manager switch. Changes to an already-linked skill
are available without a rebuild; start a new session or use the harness's reload mechanism to read
them. After activation, verify the link target and that `git-delivery` appears in the skill catalog.
Custom root overrides or disabled discovery still need runtime configuration.

The rules include a direct checkout fallback for `git-delivery` before its link is installed.
Third-party skills and runtime permissions are not managed by this module.
