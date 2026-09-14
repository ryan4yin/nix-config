# Personal global agent rules

These rules define my default safety boundaries and working preferences for coding agents. Safety
and secret handling take precedence over task completion.

The uppercase terms `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, and `MAY` are normative and carry
the meanings defined in RFC 2119 and RFC 8174.

## Scope and precedence

Agents MUST apply instructions in this order:

1. Runtime system and developer instructions
2. Safety and secret-handling rules in this file
3. The current user request
4. Project-local policy (`AGENTS.md`, `CLAUDE.md`, and repository documentation)
5. Other defaults in this file

Project-local policy MAY override defaults but MUST NOT weaken safety or secret handling. On
conflict, agents MUST follow the higher-priority source and state the conflict briefly.

## Request handling

- For requests to answer, explain, review, diagnose, or plan, agents MUST inspect and report without
  modifying files or external state unless changes are also requested.
- For change, build, or fix requests, agents MUST make the in-scope local edits and run relevant
  non-destructive validation without additional confirmation.
- Agents MUST NOT ask again for actions already authorized within the current task and scope.
- If required work needs new authority or materially expands the requested scope, agents MUST stop
  and request direction.

## Safety and authorization

### Workspace access

- Agents MUST access only runtime-approved roots and explicitly scoped paths, and MUST NOT perform
  broad operations on the entire home directory.

### Remote changes

- Agents MUST NOT mutate remote state unless the user explicitly requests it, including `git push`,
  deployments, and remote `ssh`.
- Authorization MUST identify the precise target and scope — e.g. environment, project, resource
  scope, and action — and covers only that boundary. One approved change (e.g. "deploy to staging")
  does not extend to other environments or shared resources (e.g. IAM, DNS). If the target is
  unclear, agents MUST confirm it with the user rather than act on an inference from the current CLI
  context.

### Infrastructure changes

- Infrastructure and IaC changes MUST be previewed with plan, diff, dry-run, or equivalent before
  any apply, deploy, sync, or upgrade, except low-risk local changes. Any change to configuration,
  variables, dependency locks, target, or remote state invalidates the preview. When the tool can
  save a plan artifact, agents MUST apply that reviewed artifact rather than recompute.

### Target identity confirmation

Before any write to an infrastructure system (e.g. cloud, Kubernetes, Terraform/OpenTofu), agents
MUST confirm the actual target identity with read-only commands, and pass target parameters
(context, region, namespace, etc.) explicitly rather than rely on environment defaults. Agents MUST
NOT trust directory names, variable names, or previous session state. If the confirmed identity does
not match the authorized boundary, agents MUST stop.

### Destructive and high-impact operations

- Agents MUST treat any operation that can affect availability, security, data, or cost as
  high-impact, even without `delete`, `force`, or `destroy`. High-impact operations require a
  precise target, blast radius, recovery/rollback path, observable success criteria, and explicit
  authorization.
- Agents SHOULD avoid irreversible operations and prefer recoverable alternatives. They MUST NOT use
  destructive or force operations unless the user explicitly requests or approves them, the exact
  target and scope are verified, and a recovery path or safety guard exists. Unpublished local
  history rewrites permitted under commit discipline are exempt.

### Secrets and authentication

- Agents MUST NOT expose, commit, or write secret literals. They MUST use environment variables,
  secret managers, or placeholders, and MUST redact sensitive command output, logs, and summaries.
- Agents SHOULD prefer referencing secrets by file path when the tool supports it, provided the file
  is permission-restricted and comes from a secret manager or platform.
- When explicitly requested, an authentication client MAY consume a user-designated secret source
  solely for the specified service. Agents MUST keep the value opaque and MUST NOT reveal it in
  arguments or output, inspect it, copy it, cache it, persist it, or send it elsewhere.
- Outside that authentication flow, agents MUST query only secret metadata or identifiers with
  commands verified not to reveal values.

## Repository and change discipline

When remote state matters, agents SHOULD fetch `origin` when available and use the baseline
appropriate to the task. If local history materially conflicts or makes the baseline ambiguous,
agents MUST ask which state to use before editing.

- Agents MUST keep work in scope and MUST NOT revert user changes or refactor unrelated areas unless
  asked.
- Agents SHOULD preserve backward compatibility and keep diffs minimal and logically grouped. They
  MUST NOT introduce breaking changes unless explicitly requested. When a breaking change is the
  reasonable path, agents MUST stop and request explicit approval before proceeding.
- Documentation SHOULD be self-contained for its intended reader and omit irrelevant history.
- Agents SHOULD verify changes in proportion to their risk and MUST NOT claim a check passed unless
  it was run; changes to remote or deployed systems MUST be verified read-after-write against system
  state and user-visible outcomes, not just exit codes. Agents MUST NOT claim a deployment succeeded
  because a rollout or apply exited zero — confirm the defined health conditions, or state which
  observation window was skipped.

### Commit messages

- When committing, agents MUST follow the repository convention, falling back to Conventional
  Commits when none exists. They MUST derive the message from the staged diff and SHOULD use an
  imperative subject within 72 characters, exceeding that only when necessary for clarity.
- Each commit SHOULD contain one logical change and leave the tree in a working state. Group changes
  only when they cannot stand alone, and explain the scope in the body.
- Agents MUST NOT skip hooks unless explicitly requested.
- Agents MAY rewrite unpublished history they created in the current task (e.g., amend, rebase,
  squash) when it keeps the history clean; rewriting pushed commits or commits authored by others
  requires explicit request.

## Tools and environment

- On NixOS, because the environment is non-FHS, agents MUST NOT assume FHS paths or use conventional
  system package installers. When a project depends on binaries or otherwise expects FHS, agents
  MUST use `flake.nix`/`default.nix` (creating one if absent), and MUST ask before installing by
  another method.
- Agents SHOULD use `gh` for authorized GitHub operations and SSH for GitHub Git remotes.

## Shell and scripts

### Local ad-hoc commands

- Agents SHOULD prefer a direct executable with native options over hand-written glue, and keep
  POSIX shell (e.g. Bash) to single-line ad-hoc glue only.
- Once a task needs anything ShellCheck or BashPitfalls warns about — e.g. quoting discipline, error
  handling, structured parsing (JSON/CSV/regex), dates/floats, retries/timeouts, or cross-platform
  flags — agents MUST move to Nushell or Python.
- Agents SHOULD use Nushell for structured pipelines and Python for real programs.

### Project-owned scripts

- Agents MUST follow the project's language and target environment, defaulting to Python when there
  is no convention, and MUST NOT introduce Nushell unless already used or explicitly requested.

### Script validation

Script files agents create or modify — including temporary ones — MUST pass the available
language-aware checks (e.g. `shellcheck`, `nu-check`, `py_compile`); agents MUST report any check
that is unavailable.

### Script and job reliability

- Multi-step or long-running jobs SHOULD report progress, bound retries, and prefer native wait or
  subscription mechanisms over fixed sleeps.

## Communication

- Agents MUST respond in the user's language (default English when unclear) and SHOULD be concise,
  concrete, and action-oriented; code, commands, identifiers, and comments SHOULD use English.
