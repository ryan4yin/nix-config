# agents

Portable agent resources shared across projects: the global baseline rules, behavioral scenarios for
those rules, and reference snippets for external tooling.

Home Manager links the rules from here into each agent's config location, so `agents/` itself stays
plain Markdown with no Nix dependency.

It is shared across projects. Repo-scoped task procedures for one repository belong elsewhere: put
them in that repository's `.agents/skills/` (note the leading dot), which OpenCode and compatible
tools discover automatically. In a repository, use the layers this way:

- `AGENTS.md`: always-loaded map and hard safety rules; keep it short.
- `*.md` / `README.md`: reference and domain runbooks for people, kept next to the code they
  describe.
- `.agents/skills/*/SKILL.md`: on-demand procedures, verification steps, and agent-only constraints.

Keep one canonical home for each fact; link between layers instead of copying paragraphs.

## What this directory contains

- `AGENTS.md`: global baseline rules for coding agents.
- `evals/global-rules.md`: behavioral scenarios for validating changes to the global rules.
- `install-skills.md`: curated `npx skills` command snippets, plus the `npx ctx7` docs-tool setup.

The Nix side of the agents — deploying these rules, the agent CLIs, and their environment — lives in
the Home Manager module [`home/base/tui/agents/`](../home/base/tui/agents/README.md).

## Core workflow

1. Maintain shared rules in `agents/AGENTS.md`.
2. Configure permissions directly in the agent runtime; auto-approval is generally used.
3. Edit the rules; Home Manager links them out-of-store, so the change reaches the next agent
   session without a rebuild. Run a Home Manager switch only when the deployed target set changes.
4. Use `install-skills.md` as a reference when installing external skills.

## Deployment

[`home/base/tui/agents/rules.nix`](../home/base/tui/agents/rules.nix) links `AGENTS.md` into every
supported agent config directory as an out-of-store symlink, so edits apply without a rebuild:

- Codex: `AGENTS.md` -> `${CODEX_HOME:-~/.codex}/AGENTS.md`
- OpenCode: `AGENTS.md` -> `${XDG_CONFIG_HOME:-~/.config}/opencode/AGENTS.md`
- Pi: `AGENTS.md` -> `~/.pi/agent/AGENTS.md`
- OMP: `AGENTS.md` -> `~/.omp/agent/AGENTS.md`
- Generic cross-tool (read by Kimi Code): `AGENTS.md` -> `~/.agents/AGENTS.md`

The module is imported through `home/base/tui`, so it covers the hosts that import
`home/linux/gui.nix` or the macOS `home/darwin` stack; core-only servers are unchanged.

Only `AGENTS.md` is deployed to the agents. Permission configuration and skills are not installed by
Nix; the CLIs themselves are, via the same module's `packages.nix`. The repository-root `AGENTS.md`
contains guidance for this Nix configuration repository. It is not the global rules source and is
not deployed.

Auto-approval controls tool prompting. The global rules still define task authorization, safety, and
secret handling.

## About `install-skills.md`

Use it as a snippet library:

- review the commands
- select what you need
- run selected commands manually

## TODO

Ideas worth adopting once a concrete need appears; nothing here is implemented yet.

- **Shared instructions and skills.** Deploy one rules body plus declared skills to every agent
  instead of maintaining a copy per agent. Reference: `mirkolenz/infra`
  `options/home-manager/agents.nix` (custom `programs.agents`, follows the Agent Skills spec) and
  `khaneliman/khanelinix` `modules/common/ai-tools/`.
- **Single-source permissions.** Keep allow/ask/deny command lists and agent role definitions in one
  place and render them per harness. Reference: `khaneliman/khanelinix`
  `modules/common/ai-tools/{permissions,agents}.nix`.
- **MCP from one definition.** Define MCP servers once and project them into each client. Home
  Manager ships `programs.mcp` (writes `$XDG_CONFIG_HOME/mcp/mcp.json`), but consumers still render
  it per agent. References: Home Manager `modules/programs/mcp.nix`, `jevy/home-manager-nix-config`
  `modules/dev/mcp.nix`, `dryvist/nix-ai` `modules/mcp/`.

## Conventions

- Keep files portable and reviewable.
- Keep secrets and machine-specific credentials out of this directory.
- Keep guidance generic enough to reuse across multiple agent environments.

## Goal

Maintain one reusable source of truth for agent setup that stays simple to sync and easy to evolve.
