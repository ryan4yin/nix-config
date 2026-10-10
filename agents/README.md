# Agents

Portable agent resources shared across projects: the global baseline rules, the global skills,
behavioral scenarios, and reference snippets for external tooling.

Home Manager links the rules and skills into the agents' config locations. The resource files here
remain portable Markdown; deployment lives in the Home Manager module.

Repo-scoped task procedures for one repository belong elsewhere: put them in that repository's
`.agents/skills/` (note the leading dot), which agents discover automatically. In a repository, use
the layers this way:

- `AGENTS.md`: always-loaded map and hard safety rules; keep it short.
- `agents/skills/*/SKILL.md`: custom global procedures reused across repositories.
- `*.md` / `README.md`: reference and domain runbooks for people, kept next to the code they
  describe.
- `.agents/skills/*/SKILL.md`: procedures specific to the current repository.

Keep one canonical home for each fact; link between layers instead of copying paragraphs.

## What this directory contains

- `global-rules.md`: global baseline rules for coding agents. It is deliberately not named
  `AGENTS.md`: agents working in this checkout would load it a second time as nested instructions
  for `agents/`.
- `skills/`: global skills kept in this repository, e.g.
  [`git-delivery`](skills/git-delivery/SKILL.md) for commit messages, PR descriptions, review
  replies, and cleanup after merge; its [README](skills/README.md) records every global skill and
  its source.
- `evals/global-rules.md`: how to size and run evaluations for changes to the rules or skills, and
  the behavioral scenarios.
- `install-tooling.md`: install snippets for project-scoped skills and other external agent tooling.

The Nix side of the agents — deploying the rules and skills, the agent CLIs, and their environment —
lives in the Home Manager module [`home/base/tui/agents/`](../home/base/tui/agents/README.md).

## Core workflow

1. Maintain shared boundaries in `agents/global-rules.md` and task procedures in skills.
2. Configure permissions directly in the agent runtime; auto-approval is generally used.
3. Content changes to the rules and to skills in `agents/skills/` reach the next agent session
   through out-of-store links; a running harness may need a reload. Adding or removing a skill, or
   moving a skill flake input, requires a Home Manager switch, run by the user.
4. Use `install-tooling.md` as a reference when installing project-scoped tooling.

## Maintaining global rules

Before adding or expanding a rule, read the current rules and identify the decision boundary that
needs to change. Keep reusable boundaries in `global-rules.md`; put concrete incidents, bypass
attempts, and counterexamples in [behavioral scenarios](evals/global-rules.md).

- If an existing rule already covers the incident, add or refine a scenario instead of another rule.
- If the boundary is missing or ambiguous, amend the relevant rule rather than append a special
  case.
- Keep authorization, trust, and secret-handling boundaries always loaded. Put command examples and
  task-specific procedures in reference docs or skills.
- Review the net growth and remove repetition. Brevity must preserve the boundary; verify both the
  prohibited action and the authorized action still behave as intended.

After changing the rules or a custom skill, size the evaluation to the change as the
[evaluation guide](evals/global-rules.md#choosing-the-scope) describes, and record the results in
the PR.

## Deployment

[`rules.nix`](../home/base/tui/agents/rules.nix) links `global-rules.md` into every supported agent
config directory as `AGENTS.md`, out-of-store, so edits apply without a rebuild. The per-agent
target list lives in that module's
[README](../home/base/tui/agents/README.md#deployed-rule-targets).

[`skills.nix`](../home/base/tui/agents/skills.nix) links every directory under `agents/skills/` and
the skills selected from pinned flake inputs into `~/.agents/skills/<name>`; see the module's
[global skills](../home/base/tui/agents/README.md#global-skills) section. To add a local skill,
create `agents/skills/<name>/SKILL.md`; the user activates it with a Home Manager switch. Links
point at the canonical checkout, so changes in another worktree deploy only after they are merged
there.

The module is imported through `home/base/tui`, so it covers the hosts that import
`home/linux/gui.nix` or the macOS `home/darwin` stack; core-only servers are unchanged.

Permission configuration is not managed by Nix. The repository-root `AGENTS.md` contains guidance
for this Nix configuration repository only; it is not deployed.

Auto-approval controls tool prompting. The global rules still define task authorization, safety, and
secret handling.

## TODO

Remaining work on the agent context, ordered by expected payoff. The goal is fewer tokens per
session and closer adherence to these rules. Done so far: the rules source rename, the move of
global skills to flake inputs (dropping superpowers, `find-skills`, and `caveman`), the i-have-adhd
always-on block, and the table-padding and duplication cleanup in the repo skills. Four rounds were
tested with [behavioral scenarios](evals/global-rules.md) on `gpt-6-luna`, then the local model,
then `gpt-6.1-sol`: tool-execution compression, a whole-file compression, boundaries for readiness
waits, process inspection, and shell command sequencing, and a paper pass over the full scenario
tables on `gpt-6-luna` and `DeepSeek-V41-Flash`. The file is 14,989 characters, 213 above the
version on `main`: the boundaries written down cost more than the compression saved. On `gpt-6-luna`
the compression round took clean readiness waits from 0 of 4 to 4 of 4, and answers that assumed a
shell variable survived between calls from 2 of 4 to 0 of 4.

- **Fold `mattpocock/skills` `pr` into `git-delivery`**: before/after evidence, one-way or two-way
  door, and blast radius for PR bodies.
- **Write a `testing-strategy` skill**: E2E of real workflows first, unit tests for logic and edge
  cases E2E cannot reach.
- **Merge `ponytail-review` with a comment and doc pruning pass** (reference:
  `MidAutumnMoon/TaysiTsuki` `home/agents/skills/prune-comments-and-docs`). Worth borrowing from
  `garrytan/gstack` `review/checklist.md`: a critical pass before an informational one, reading
  consumers outside the diff for a new enum value or loosened validator, a do-not-flag list, and
  "zero findings is valid". Keep review report-only.
- **Adapt `wayfinder` in the fork** so its map and tickets default to local Markdown and research
  stays local, instead of GitHub issues and pushed `research/` branches.
- **Adapt `domain-modeling` in the fork** to record decisions in the repository's existing documents
  (here `AGENTS.md`, `WORKAROUNDS.md`, `SECURITY.md`, READMEs) and create `GLOSSARY.md` or ADRs only
  where none exist.
- **Trim `find-docs`**: its description (~930 characters) is the longest in the catalog and says
  "always use", and its body runs `npx ctx7@latest` unpinned and suggests `npm install -g`.
- **Borrow small gstack ideas into the rules**: completion statuses (done, done with concerns,
  blocked, needs context); never call a failure pre-existing without running the same check on the
  base branch; a subagent with no one to ask takes the recommended option but never a destructive or
  publishing one.
- **Use progressive disclosure for large repo skills.** `nix-config-umu-game` (~3.5k tokens) keeps
  its troubleshooting inline; move it to a reference file. Lower priority: `nix-config-secrets` §7
  and `nixpkgs-review` §3.
- **Budget the always-loaded context in CI**: cap skill description length and rules size, as gstack
  does for its catalog.
- **MCP servers** are still configured by hand per harness; they could come from the same Nix
  source, though config formats differ per client. Reference: `mirkolenz/infra`
  `options/home-manager/agents.nix`.

## Conventions

- Keep files portable and reviewable.
- Keep secrets and machine-specific credentials out of this directory.
- Keep guidance generic enough to reuse across multiple agent environments.
