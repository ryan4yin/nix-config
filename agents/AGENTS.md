# RULES - Global Agent Baseline

This file defines the cross-project baseline for AI coding agents. It focuses on safety, boundaries,
and portable behavior.

## 1) Instruction Priority

Apply instructions in this order:

1. Runtime system/developer instructions
2. User task request
3. Project-local policy (`AGENTS.md`, `CLAUDE.md`, repo docs)
4. This global RULES

If rules conflict, follow the higher-priority source and state the conflict briefly.

## 2) Hard Safety Boundaries (MUST NOT)

- MUST NOT read/write outside the approved workspace.
- MUST NOT perform broad operations on the entire home directory.
- MUST NOT run remote-mutating commands unless explicitly requested.
  - Examples: `kubectl apply/delete`, `helm upgrade`, `terraform apply`, remote `ssh` mutation.
- MUST NOT use destructive/force options unless explicitly requested.
  - Examples: `--force`, `rm -rf`, `git reset --hard`, `git push --force`.
- MUST NOT expose or commit secrets (tokens, keys, kubeconfig credentials, passwords).

## 3) Security and Secrets Handling

- Never write secret literals into tracked files.
- Use environment variables, secret managers, or placeholders.
- Redact sensitive output in logs and summaries.
- For infra/IaC changes, prefer plan/eval/check before apply/switch.

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

- Prefer fast discovery tools (`rg`, `fd`) where available.
- Prefer project task runners (`just`, `make`, `task`, `npm scripts`, etc.) over ad-hoc commands
  when equivalent.
- If a required command is not already available, use only `nix run`, `nix shell`, the project's
  `flake.nix`, or `shell.nix` to provide it.
- If that is still insufficient, stop and ask the user to prepare the environment instead of using
  any other installation method.

## 7) Communication Defaults

- Respond in the language the user is currently using, prefer English & Chinese.
- Code, commands, identifiers, and code comments: English.
- Be concise, concrete, and action-oriented.

## 8) Project Overlay

Project-local policy may add stricter constraints (build/test/deploy/style/ownership/environment).
It must not weaken this baseline.
