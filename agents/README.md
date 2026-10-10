# Agents

Portable agent resources shared across projects: the global baseline rules, custom global skills,
behavioral scenarios, and reference snippets for external tooling.

Home Manager links the rules and each custom skill into the agents' config locations. The resource
files here remain portable Markdown; deployment lives in the Home Manager module.

It is shared across projects. Repo-scoped task procedures for one repository belong elsewhere: put
them in that repository's `.agents/skills/` (note the leading dot), which OpenCode and compatible
tools discover automatically. In a repository, use the layers this way:

- `AGENTS.md`: always-loaded map and hard safety rules; keep it short.
- `agents/skills/*/SKILL.md`: custom global procedures reused across repositories.
- `*.md` / `README.md`: reference and domain runbooks for people, kept next to the code they
  describe.
- `.agents/skills/*/SKILL.md`: procedures specific to the current repository.

Keep one canonical home for each fact; link between layers instead of copying paragraphs.

## What this directory contains

- `AGENTS.md`: global baseline rules for coding agents.
- [`skills/git-delivery/SKILL.md`](skills/git-delivery/SKILL.md): context, commit and PR writing,
  verification evidence, hosting tools, and cleanup after merge. Read its
  [portable examples](skills/git-delivery/examples.md) for non-obvious constraints and repository
  conventions.
- `evals/global-rules.md`: behavioral scenarios for validating changes to the global rules.
- `install-tooling.md`: curated install snippets for external agent tooling (`npx skills`,
  `npx ctx7`, tuios integration).

The Nix side of the agents — deploying these rules, the agent CLIs, and their environment — lives in
the Home Manager module [`home/base/tui/agents/`](../home/base/tui/agents/README.md).

## Core workflow

1. Maintain shared boundaries in `agents/AGENTS.md` and task procedures in `agents/skills/`.
2. Configure permissions directly in the agent runtime; auto-approval is generally used.
3. Content changes reach the next agent session through out-of-store links; a running harness may
   need a reload. Adding or removing deployed links requires a Home Manager switch, run by the user.
4. Use `install-tooling.md` as a reference when installing external agent tooling.

## Maintaining global rules

Before adding or expanding a rule, read the current rules and identify the decision boundary that
needs to change. Keep reusable boundaries in `AGENTS.md`; put concrete incidents, bypass attempts,
and counterexamples in [behavioral scenarios](evals/global-rules.md).

- If an existing rule already covers the incident, add or refine a scenario instead of another rule.
- If the boundary is missing or ambiguous, amend the relevant rule rather than append a special
  case.
- Keep authorization, trust, and secret-handling boundaries always loaded. Put command examples and
  task-specific procedures in reference docs or skills.
- Review the net growth and remove repetition. Brevity must preserve the boundary; verify both the
  prohibited action and the authorized action still behave as intended.

Run the scenarios required by the evaluation guide after rule changes, and record their results.

## Deployment

[`home/base/tui/agents/rules.nix`](../home/base/tui/agents/rules.nix) links `AGENTS.md` into every
supported agent config directory as an out-of-store symlink, so edits apply without a rebuild. The
per-agent target list lives in that module's
[README](../home/base/tui/agents/README.md#deployed-rule-targets).

The module is imported through `home/base/tui`, so it covers the hosts that import
`home/linux/gui.nix` or the macOS `home/darwin` stack; core-only servers are unchanged.

[`home/base/tui/agents/skills.nix`](../home/base/tui/agents/skills.nix) links each custom skill
directory into `~/.agents/skills/<name>`. It leaves the parent directory and third-party skills
unmanaged. Permission configuration and third-party skill installation remain runtime-managed; the
agent CLIs are installed through `packages.nix`.

To add a custom global skill:

1. Create `agents/skills/<name>/SKILL.md` with matching `name` and a `description` that identifies
   when to load it. Keep reusable details there and safety boundaries in the rules.
2. Add an explicit per-directory out-of-store link in `skills.nix`; never link the whole skill root
   or enable forced replacement. Check for a conflicting existing directory before activation and
   resolve its ownership with the user rather than overwriting it.
3. Validate the skill's behavior and Linux/Darwin configuration, then have the user activate the
   links and verify discovery in a new session. Current Codex, OpenCode, Pi, and dsh releases use
   the shared root; see the module's
   [discovery references](../home/base/tui/agents/README.md#global-skills).

`AGENTS.md` provides a direct source fallback for `git-delivery`, so the procedure stays accessible
before activating its link. Out-of-store links point at the canonical checkout; a separate worktree
must be merged into that checkout before its content is deployed.

The repository-root `AGENTS.md` contains guidance for this Nix configuration repository. It is not
the global rules source and is not deployed.

Auto-approval controls tool prompting. The global rules still define task authorization, safety, and
secret handling.

## About `install-tooling.md`

Use it as a snippet library:

- review the commands
- select what you need
- run selected commands manually

## TODO

Ideas worth adopting once a concrete need appears; nothing here is implemented yet.

- **Unified third-party skill and MCP management.** Third-party skills are installed with
  `npx skills` and MCP servers are configured by hand per harness; custom global skills already have
  Home Manager links. A single source for the remaining tools would be nicer, though MCP config
  formats differ per client. Reference: `mirkolenz/infra` `options/home-manager/agents.nix` (custom
  `programs.agents`, follows the Agent Skills spec).

## Conventions

- Keep files portable and reviewable.
- Keep secrets and machine-specific credentials out of this directory.
- Keep guidance generic enough to reuse across multiple agent environments. Repository contribution
  policies remain the source for commit formats, required metadata, and upstream review
  requirements.

Useful writing references:
[GitHub's commit skill](https://github.com/github/awesome-copilot/blob/main/skills/git-commit/SKILL.md),
[Sentry's PR writer](https://github.com/getsentry/skills/blob/main/skills/pr-writer/SKILL.md),
[Nixpkgs contribution guidance](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md), and
[prune-comments-and-docs](https://github.com/MidAutumnMoon/TaysiTsuki/blob/master/home/agents/skills/prune-comments-and-docs/SKILL.md).
These are references, not installed skills or additional authorization.
