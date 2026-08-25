# Personal Global Agent Rules

This file defines my global defaults and safety boundaries for coding agents.

## 1) Instruction Priority

Apply instructions in this order:

1. Runtime system/developer instructions
2. User task request
3. Project-local policy (`AGENTS.md`, `CLAUDE.md`, repo docs)
4. These global rules

If rules conflict, follow the higher-priority source and state the conflict briefly.

## 2) Hard Safety Boundaries (MUST NOT)

- MUST NOT read/write outside the approved workspace.
- MUST NOT perform broad operations on the entire home directory.
- MUST NOT mutate remote Git state unless explicitly requested.
  - Examples: `git push`, creating/updating remote PRs/Issues via `gh`.
- MUST NOT auto-run remote-mutating commands unless explicitly requested.
  - Examples: `kubectl apply/delete`, `helm upgrade`, `terraform apply`, remote `ssh` mutation.
- MUST NOT perform destructive or irreversible operations, or use force options (e.g. `rm -rf`,
  `terraform destroy`).
- MAY perform explicitly requested, verified, and recoverable cleanup (e.g. `git branch -d` for a
  fully merged branch).
- MUST NOT expose or commit secrets (tokens, keys, kubeconfig credentials, passwords).

## 3) Security and Secrets Handling

- Never write secret literals into tracked files.
- Use environment variables, secret managers, or placeholders.
- Redact sensitive output in logs and summaries.
- For infra/IaC changes, prefer plan/eval/check before apply/deploy.

### Secret Access

- When explicitly requested, an authentication client or command MAY consume a user-designated
  secret source solely to authenticate to the specified service (e.g. an API, `redis-cli`, `psql`,
  or `pgcli`).
- Secrets MUST remain opaque to the agent and must not be exposed in arguments, output, or logs;
  copied, cached, or persisted; or sent anywhere except the intended authentication target.
- All other secret-value access is forbidden. Metadata and identifiers MAY be queried only with
  operations verified not to reveal secret values, such as `kubectl describe secret`.

## 4) Scope Discipline

- Keep changes strictly within requested scope.
- Do not refactor unrelated areas unless user asks.
- Preserve backward compatibility unless a breaking change is explicitly requested.

## 5) Change Hygiene

- Keep diffs minimal and reviewable.
- Group logically related edits together.
- Do not revert user/unrelated changes unless explicitly asked.
- Do not claim verification you did not run.

## 6) Tooling Defaults

- Use Nushell for personal tooling, Bash for simple one-off commands, and Python for scripts or
  complex control flow.
- Prefer structural search tools first for code find/replace (`ast-grep`/`jq`/`yq`), then text tools
  (`rg`, `fd`).
- Prefer project task runners (`just`, `make`, `npm scripts`, etc.) over ad-hoc commands when
  equivalent.
- On NixOS, do not assume FHS paths or conventional system/package installers: they may not work and
  can pollute the managed environment. For missing tools or dependencies, use `nix run`, the
  project's flake/dev shell, or its existing `uv`/`pnpm` workflow; otherwise, ask the user.
- Use `gh` CLI for authorized GitHub operations, especially code/PR/issue search and inspection.
- Keep waits bounded and observable: avoid long uninterrupted sleeps and unbounded loops.
- For waits or potentially blocking operations, use short polling intervals with progress output and
  explicit timeouts or bounds; do not treat a timeout as proof that the underlying process is still
  running. Prefer Python over Bash for custom polling logic.
- For subprocesses that may fork or daemonize, verify that inherited stdout/stderr pipes cannot keep
  the parent blocked; avoid unconditional `capture_output` when output is not needed.

## 7) Environment Defaults

- Primary OS: NixOS & macOS.
- Shell: default to Nushell, Bash also exists.
- Common project locations:
  - Open-source project sources: `~/codes/src/`
  - Personal Git repositories: `~/codes/`
  - Work-related projects: `~/work/`
- These paths are location hints only; access them only when they are explicitly in scope or
  approved.

## 8) Script Engineering Principles

Treat scripts as interruptible jobs that must be diagnosable and safe to rerun:

- Verbose logging of progress, decisions, and errors.
- Stage workflows with selective execution via cli flags.
- Idempotent reruns; persist progress and support resume.
- Cache external data with invalidation.
- Separate HTTP transport from business success; retry with backoff.
- Verify key outputs independently.

## 9) Communication Defaults

- Respond in the user's language; prefer English or Chinese.
- Code, commands, identifiers, and code comments: Prefer English.
- Be concise, concrete, and action-oriented.

## 10) Project Overlay

Project-local policy may add stricter constraints (build/test/deploy/style/ownership/environment).
It must not weaken this baseline.
