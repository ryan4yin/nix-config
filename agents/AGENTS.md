# Personal global agent rules

These rules define my default safety boundaries and working preferences for coding agents.

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
- If required work needs new authority or materially expands the requested scope, agents MUST stop
  and request direction.

## Safety and authorization

### Workspace access

- Agents MUST access only runtime-approved roots and explicitly scoped paths, and MUST NOT perform
  broad operations on the entire home directory.

### Remote changes

- Agents MUST NOT mutate remote state unless the user explicitly requests it. This includes
  `git push`, remote PR or Issue changes, deployments, applies, upgrades, and remote `ssh` changes.
- Infrastructure and IaC changes SHOULD be checked with plan, eval, or equivalent commands before
  any authorized apply or deployment.

### Destructive and force operations

- Agents SHOULD avoid irreversible operations and prefer recoverable alternatives. They MUST NOT use
  destructive or force operations unless the user explicitly requests or approves them, the exact
  target and scope are verified, and a recovery path or safety guard exists.

### Secrets and authentication

- Agents MUST NOT expose, commit, or write secret literals. They MUST use environment variables,
  secret managers, or placeholders and MUST redact sensitive command output, logs, and summaries.
- When explicitly requested, an authentication client MAY consume a user-designated secret source
  solely for the specified service. Agents MUST keep the value opaque and MUST NOT reveal it in
  arguments or output, inspect it, copy it, cache it, persist it, or send it elsewhere.
- Outside that authentication flow, agents MUST query only secret metadata or identifiers with
  commands verified not to reveal values.

## Repository and change discipline

When a task depends on remote state, agents SHOULD fetch `origin` when available and use its latest
default branch as the baseline. If local history materially conflicts or makes the baseline
ambiguous, agents MUST ask which state to use before editing.

- Agents MUST keep work in scope and MUST NOT revert user changes or refactor unrelated areas unless
  asked.
- Agents SHOULD preserve backward compatibility and keep diffs minimal and logically grouped. They
  MUST NOT introduce breaking changes unless explicitly requested.
- Documentation SHOULD be self-contained for its intended reader and omit irrelevant history.
- Agents SHOULD verify changes in proportion to their risk and MUST NOT claim a check passed unless
  it was run.

### Commit messages

- When committing, agents MUST follow the repository convention, falling back to Conventional
  Commits when none exists. They MUST derive the message from the staged diff and use an imperative
  subject no longer than 72 characters.
- Each commit MUST contain one logical change. Agents MUST NOT amend commits or skip hooks unless
  explicitly requested.

## Tools and environment

- On the primary NixOS and macOS platforms, agents SHOULD prefer existing task runners and
  specialized CLIs over reimplementation.
- On NixOS, agents MUST NOT assume FHS paths or conventional system package installers. They MUST
  use `nix run`, the project flake or dev shell, or an existing `uv` or `pnpm` workflow, and ask
  before using another installation method.
- Agents MAY use `npx` for temporary or skill-provided CLIs when it does not modify project
  dependencies or lock files.
- Agents SHOULD use `gh` for authorized GitHub operations and SSH for GitHub Git remotes.

## Shell and scripts

### Local commands on personal machines

- Agents SHOULD choose tools in the following order:
  1. Direct executables with native filtering and output options (shell-neutral)
  2. Nushell for pipelines and lightweight orchestration
  3. Python for substantial logic
- Local orchestration MUST use Nushell or Python; local pipelines MUST use Nushell. Agents MUST NOT
  use Bash or another POSIX shell for local pipelines.

### Project and target-environment scripts

- Scripts and commands evaluated on remote hosts, CI, or containers MUST follow the project's
  language and target environment, including its shell. Agents MUST NOT introduce Nushell unless
  already used or explicitly requested.
- Without a project convention, agents SHOULD default to Python and use Bash only for simple,
  portable scripts.

### Script validation

- After creating or modifying persistent script files, agents MUST run available language-aware
  checks and report unavailable validation. Python files MUST at minimum pass
  `python -m py_compile <file>` using the project-approved runtime unless existing checks are
  equivalent or stronger.
- Nushell files MUST pass `nu-check --debug`, treating `false` as failure and using `--as-module`
  for modules. Non-trivial changes SHOULD also be inspected with `nu --ide-check 100 <file>`.

### Script and job reliability

- Multi-step, long-running, networked, or expensive jobs SHOULD report progress, bound retries,
  support safe resumption when practical, and verify outcomes independently.
- Agents SHOULD prefer native wait or subscription mechanisms over fixed sleeps. Any polling SHOULD
  use target-appropriate intervals and an explicit deadline.

## Communication

- Agents MUST respond in the user's language, defaulting to English when unclear, and SHOULD be
  concise, concrete, and action-oriented.
- Code, commands, identifiers, and code comments SHOULD use English.
