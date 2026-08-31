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
- Agents MUST NOT access secret values for any other purpose. They MUST query metadata or
  identifiers only with commands verified not to reveal values, such as `kubectl describe secret`.

## Repository state

Once at the start of each repository session, agents SHOULD fetch `origin` when it exists and
network access is available, then SHOULD use its latest default branch as the baseline. If local
history differs in a way that materially affects the requested work or makes the baseline ambiguous,
agents MUST ask which state to use before editing.

## Change discipline

- Agents MUST keep work within the requested scope and MUST NOT refactor unrelated areas unless
  asked.
- Agents MUST preserve backward compatibility unless the user explicitly requests a breaking change.
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
- Agents MUST use SSH URLs for GitHub Git remotes and MUST preserve the existing SSH config. They
  MUST NOT override it with `ssh -F /dev/null` or `GIT_SSH_COMMAND`. If sandbox ownership checks
  reject the Nix-managed config, agents MUST rerun the original Git command with elevated
  permission.

## Shell and scripts

- Agents SHOULD invoke an executable directly when one command is sufficient; direct invocations are
  shell-neutral and need no wrapper.
- Local orchestration on the user's personal machines MUST use Nushell and structured values. Any
  pipeline evaluated on the user's personal machine MUST use Nushell. Agents MUST NOT use POSIX
  text-pipeline orchestration locally, such as `command | grep ... | sed ... | head ...` (it is
  fragile around whitespace, newlines, escaping, exit codes, binary data, and platform differences).
- For local command execution, agents SHOULD choose tools in the following order:
  1. Native CLI filtering and output options
  2. Nushell structured pipelines
  3. Python for substantial logic
- Commands evaluated on remote hosts, CI, or containers MUST use the target environment's shell.
- Project scripts intended to run outside the user's personal machines MUST follow the project's
  existing language and target environment.
- Agents MUST NOT introduce Nushell into such project scripts unless the project already uses it or
  the user explicitly requests it.
- When a project has no existing convention, agents SHOULD use Bash for simple portable scripts and
  Python for substantial logic.
- Agents SHOULD use native wait or subscription tools. Otherwise, they MUST poll with progress and
  an explicit deadline, using intervals of a few seconds for short-lived local validation. A timeout
  does not prove the process is still running.
- For processes started by the agent, agents MUST track and wait on the child PID or process handle
  directly and MUST NOT infer liveness by matching `ps` or `pgrep` output.
- For long-running, batch, networked, or expensive jobs, agents SHOULD log progress and, when
  practical, SHOULD support selective stages, idempotent reruns, resume, cache invalidation, and
  transient retries. Agents SHOULD distinguish HTTP success from business success and SHOULD verify
  important outputs independently.

## Communication

- Agents MUST respond in the user's language and SHOULD default to English when it is unclear.
- Agents SHOULD use English for code, commands, identifiers, and code comments.
- Agents SHOULD be concise, concrete, and action-oriented.
