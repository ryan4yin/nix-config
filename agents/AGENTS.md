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
- MUST NOT mutate remote Git state unless explicitly requested.
  - Examples: `git push`, `git push --force`, creating/updating remote PRs.
- MUST NOT auto-run remote-mutating commands unless explicitly requested.
  - Examples: `kubectl apply/delete`, `helm upgrade`, `terraform apply`, remote `ssh` mutation.
- MUST NOT use destructive/force/delete options EVEN explicitly requested.
  - Examples: `--force`, `rm -rf`, `git reset --hard`, `git push --force`, `gh repo delete`,
    `gh issue delete`
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

- Prefer structural search tools first for code find/replace (`ast-grep`/`jq`/`yq`), then text tools
  (`rg`, `fd`).
- Prefer project task runners (`just`, `make`, `task`, `npm scripts`, etc.) over ad-hoc commands
  when equivalent.
- If a required command is not already available, use only `nix run`, `flake.nix`/`shell.nix` or
  `uv`/`pnpm` to provide it.
- If that is still insufficient, stop and ask the user to prepare the environment instead of using
  any other installation method.
- Use `gh` CLI for GitHub operations, especially code/PR/issue search and inspection.

## 7) Environment Defaults

- Primary OS: NixOS.
- Shell: default to `nushell`, `bash` also exists.

## 8) Script Engineering Principles

Treat scripts as interruptible jobs that must be diagnosable and safe to rerun:

- Split workflows into explicit stages; allow running a selected stage via flags/arguments.
- Make reruns idempotent; persist progress after each stage and support resume.
- Cache external data with invalidation strategy to speed retries and improve reproducibility.
- For HTTP flows, separate transport success from business success; support retry/backoff.
- Provide independent verification commands/checks for key outputs (counts, samples, invariants).

## 9) Communication Defaults

- Respond in the language the user is currently using, prefer English & Chinese.
- Code, commands, identifiers, and code comments: English.
- Be concise, concrete, and action-oriented.

## 10) Project Overlay

Project-local policy may add stricter constraints (build/test/deploy/style/ownership/environment).
It must not weaken this baseline.
