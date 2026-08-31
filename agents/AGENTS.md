# Personal global agent rules

These rules define my default safety boundaries and working preferences for coding agents.

## Scope and precedence

Apply instructions in this order:

1. Runtime system and developer instructions
2. The current user request
3. Safety and secret-handling rules in this file
4. Project-local policy (`AGENTS.md`, `CLAUDE.md`, and repository documentation)
5. Other defaults in this file

Project-local policy may override global defaults but must not weaken safety or secret handling.
Follow the higher-priority source when rules conflict and state the conflict briefly.

## Safety and authorization

### Workspace access

- Access only runtime-approved roots and paths explicitly placed in scope.
- Do not perform broad operations on the entire home directory.

### Remote changes

- Do not mutate remote state unless the user explicitly requests it.
- Remote mutations include `git push`, creating or updating remote PRs and Issues via `gh`,
  `kubectl apply/delete`, `helm upgrade`, `terraform apply`, and remote `ssh` changes.
- For infrastructure and IaC changes, prefer plan, eval, or check commands before applying or
  deploying.

### Destructive and force operations

- Avoid irreversible operations.
- Use destructive or force options only when the user explicitly requests or approves them, the
  exact target and scope have been verified, and a recovery path or safety guard is available.
- Prefer recoverable alternatives and safeguards such as `git branch -d` and
  `git push --force-with-lease`.

### Secrets and authentication

- Never expose or commit tokens, keys, passwords, kubeconfig credentials, or other secrets.
- Never write secret literals into tracked files. Use environment variables, secret managers, or
  placeholders.
- Redact sensitive values from command output, logs, and summaries.
- When explicitly requested, an authentication client may consume a user-designated secret source
  only to authenticate to the specified service.
- Keep secrets opaque. Do not expose them in arguments or output, copy them, cache them, persist
  them, or send them anywhere except the intended authentication target.
- Do not access secret values for any other purpose. Query metadata or identifiers only with
  commands verified not to reveal values, such as `kubectl describe secret`.

## Repository state

Once at the start of each repository session:

- Fetch `origin` when available and use its latest default branch as the baseline.
- If local history differs, ask which state to use before editing.

## Change discipline

- Keep work within the requested scope. Do not refactor unrelated areas unless asked.
- Preserve backward compatibility unless the user explicitly requests a breaking change.
- Keep diffs minimal, reviewable, and grouped by logical purpose.
- Do not revert user changes or unrelated changes unless explicitly asked.
- Write for the intended reader and make documentation self-contained. Omit prior states, mistakes,
  and surrounding context unless they are relevant and necessary for the reader's task.
- Verify changes in proportion to their risk. Never claim a check passed unless it was run.

### Commit messages

- Follow the repository convention. Otherwise, use Conventional Commits.
- Derive the message from the staged diff and use an imperative subject no longer than 72
  characters.
- Keep one logical change per commit. Do not amend commits or skip hooks unless explicitly
  requested.

## Tools and environment

- Primary platforms are NixOS and macOS.
- Prefer existing task runners and specialized CLI tools over reimplementing their behavior.
- **Use Python for ad hoc scripts or composed logic.** Use Bash only for simple one-shot commands
  that are clearly shorter and verified. Simple one-shot Python scripts do not require tests.
- On NixOS, do not assume FHS paths or conventional system package installers. Use `nix run`, the
  project flake or dev shell, or the project's existing `uv` or `pnpm` workflow. Ask before using a
  different installation method.
- `npx` is allowed for temporary or skill-provided CLIs when it does not modify project dependencies
  or lock files.
- Use `gh` for authorized GitHub operations, especially code, PR, and Issue search or inspection.
- Use SSH URLs for GitHub Git remotes and preserve the existing SSH config; do not override it with
  `ssh -F /dev/null` or `GIT_SSH_COMMAND`. If sandbox ownership checks reject the Nix-managed
  config, rerun the original Git command with elevated permission.

## Commands and scripts

- Prefer native wait or subscription tools. Otherwise, poll with progress and an explicit deadline,
  using intervals of a few seconds for short-lived local validation. A timeout does not prove the
  process is still running.
- For processes started by the agent, track and wait on the child PID or process handle directly. Do
  not infer liveness by matching `ps` or `pgrep` output.
- For long-running, batch, networked, or expensive jobs, log progress and, when practical, support
  selective stages, idempotent reruns, resume, cache invalidation, and transient retries;
  distinguish HTTP success from business success and verify important outputs independently.

## Communication

- Respond in the user's language; default to English when it is unclear.
- Prefer English for code, commands, identifiers, and code comments.
- Be concise, concrete, and action-oriented.
