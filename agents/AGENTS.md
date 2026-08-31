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

Project-local policy MAY override global defaults but MUST NOT weaken safety or secret handling.
Agents MUST follow the higher-priority source when rules conflict and MUST state the conflict
briefly.

## Request handling

- For requests to answer, explain, review, diagnose, or plan, agents MUST inspect the relevant
  materials and report the result. They MUST NOT modify files or external state unless the request
  also asks for changes.
- For requests to change, build, or fix, agents MUST make the requested in-scope local edits and run
  relevant non-destructive validation without additional confirmation.
- If required work needs new authority or materially expands the requested scope, agents MUST stop
  and request direction.

## Safety and authorization

### Workspace access

- Agents MUST access only runtime-approved roots and paths explicitly placed in scope.
- Agents MUST NOT perform broad operations on the entire home directory.

### Remote changes

- Agents MUST NOT mutate remote state unless the user explicitly requests it.
- Remote mutations include `git push`, creating or updating remote PRs and Issues via `gh`,
  `kubectl apply/delete`, `helm upgrade`, `terraform apply`, and remote `ssh` changes.
- For infrastructure and IaC changes, agents SHOULD use plan, eval, or check commands before
  applying or deploying.

### Destructive and force operations

- Agents SHOULD NOT perform irreversible operations.
- Agents MUST NOT use destructive or force options unless the user explicitly requests or approves
  them, the exact target and scope have been verified, and a recovery path or safety guard is
  available.
- Agents SHOULD use recoverable alternatives and safeguards such as `git branch -d` and
  `git push --force-with-lease`.

### Secrets and authentication

- Agents MUST NOT expose or commit tokens, keys, passwords, kubeconfig credentials, or other
  secrets.
- Agents MUST NOT write secret literals into tracked files. They MUST use environment variables,
  secret managers, or placeholders.
- Agents MUST redact sensitive values from command output, logs, and summaries.
- When explicitly requested, an authentication client MAY consume a user-designated secret source
  solely to authenticate to the specified service.
- Agents MUST keep secrets opaque. They MUST NOT expose them in arguments or output, copy them,
  cache them, persist them, or send them anywhere except the intended authentication target.
- Agents MUST NOT access secret values for any other purpose. They MUST query only metadata or
  identifiers, using commands verified not to reveal secret values.

## Repository state

When the task depends on current remote state, agents SHOULD fetch `origin` when it exists and
network access is available, then SHOULD use its latest default branch as the baseline. If local
history differs in a way that materially affects the requested work or makes the baseline ambiguous,
agents MUST ask which state to use before editing.

## Change discipline

- Agents MUST keep work within the requested scope and MUST NOT refactor unrelated areas unless
  asked.
- Agents SHOULD preserve backward compatibility. They MUST NOT introduce a breaking change unless
  the user explicitly requests it.
- Agents SHOULD keep diffs minimal, reviewable, and grouped by logical purpose.
- Agents MUST NOT revert user changes or unrelated changes unless explicitly asked.
- Agents SHOULD write for the intended reader and make documentation self-contained. Documentation
  SHOULD omit prior states, mistakes, and surrounding context unless they are relevant and necessary
  for the reader's task.
- Agents SHOULD verify changes in proportion to their risk and MUST NOT claim a check passed unless
  it was run.

### Commit messages

- Agents MUST follow the repository convention. Otherwise, they MUST use Conventional Commits.
- Agents MUST derive the message from the staged diff and MUST use an imperative subject no longer
  than 72 characters.
- Agents MUST keep one logical change per commit and MUST NOT amend commits or skip hooks unless
  explicitly requested.

## Tools and environment

- Primary platforms are NixOS and macOS.
- Agents SHOULD use existing task runners and specialized CLI tools instead of reimplementing their
  behavior.
- On NixOS, agents MUST NOT assume FHS paths or conventional system package installers. They MUST
  use `nix run`, the project flake or dev shell, or the project's existing `uv` or `pnpm` workflow,
  and MUST ask before using a different installation method.
- Agents MAY use `npx` for temporary or skill-provided CLIs when it does not modify project
  dependencies or lock files.
- Agents SHOULD use `gh` for authorized GitHub operations, especially code, PR, and Issue search or
  inspection.
- Agents SHOULD prefer SSH for GitHub Git remotes.

## Shell and scripts

### Local commands on personal machines

- Agents SHOULD choose tools in the following order:
  1. Direct executables with native filtering and output options (shell-neutral)
  2. Nushell for pipelines and lightweight orchestration
  3. Python for substantial logic
- Local orchestration MUST use Nushell or Python; local pipelines MUST use Nushell. Agents MUST NOT
  use Bash or another POSIX shell for local pipelines, such as
  `command | grep ... | sed ... | head ...` (fragile around whitespace, newlines, escaping, exit
  codes, binary data, and platform differences).

### Project and target-environment scripts

- Project scripts and commands evaluated on remote hosts, CI, or containers MUST follow the
  project's language and target environment, including its shell.
- Agents MUST NOT introduce Nushell unless the project already uses it or the user explicitly
  requests it.
- When no project convention exists, agents SHOULD use Python by default and Bash only for simple
  portable scripts.

### Script and job reliability

- Multi-step, long-running, networked, or expensive scripts and jobs SHOULD report progress, bound
  retries, support safe resumption when practical, and verify outcomes independently.
- Agents SHOULD prefer native wait or subscription mechanisms over fixed sleeps. Polling SHOULD use
  short, target-appropriate intervals and an explicit deadline.

## Communication

- Agents MUST respond in the user's language and SHOULD default to English when it is unclear.
- Agents SHOULD use English for code, commands, identifiers, and code comments.
- Agents SHOULD be concise, concrete, and action-oriented.
