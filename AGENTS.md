# AGENTS.md - Guidelines for AI Coding Agents

This file defines the default operating guide for AI agents working in this Nix Flake repository.
Keep changes minimal, verifiable, and safe for multi-host deployments.

## Scope and Repository Model

This repository manages:

- NixOS hosts (desktop + servers)
- macOS hosts via nix-darwin
- Home Manager profiles shared across platforms
- Remote deployments via colmena

High-level layout:

```text
.
├── flake.nix                    # Flake entry; outputs composed in ./outputs
├── Justfile                     # Primary command entrypoint (uses nushell)
├── outputs/
│   ├── default.nix
│   ├── x86_64-linux/
│   ├── aarch64-linux/
│   └── aarch64-darwin/
├── modules/                     # NixOS + darwin modules
├── home/                        # Home Manager modules
├── hosts/                       # Host-specific config
├── vars/                        # Shared variables
├── lib/                         # Helper functions
└── secrets/                     # Agenix secret definitions
```

## Ground Rules for Agents

- Prefer `just` tasks over ad-hoc commands when an equivalent task exists.
- Make the smallest reasonable change; avoid drive-by refactors.
- Do not commit secrets, generated credentials, or private keys.
- Preserve platform guards (`[linux]`, `[macos]`) and host naming conventions.
- Run formatting and evaluation checks for touched areas before finishing.

## Quick Start Workflow (Recommended)

1. Inspect context:

```bash
just --list
rg -n "<symbol-or-option>" modules home hosts outputs
```

2. Implement the change.
3. Format:

```bash
just fmt
```

4. Validate:

```bash
just test
```

5. If deployment behavior changed, provide the exact `just` command the user should run (do not run
   remote deploys unless explicitly requested).

## Canonical Commands

### Core quality loop

```bash
just fmt                    # format Nix files
just test                   # run eval tests: nix eval .#evalTests ...
nix flake check             # run flake checks + pre-commit style checks
```

### Dependency/input updates

```bash
just up                     # update all inputs and commit lock file
just upp <input>            # update one input and commit lock file
just up-nix                 # update nixpkgs-related inputs
```

### Local deploy commands

```bash
just local                  # deploy config for current hostname
just local debug            # same with verbose/debug mode
just niri                   # deploy "<hostname>-niri" on Linux
just niri debug             # debug mode
```

### Remote deploy commands (colmena)

```bash
just col <tag>              # deploy nodes matching tag
just lab                    # deploy all kubevirt nodes
just k3s-prod               # deploy k3s production nodes
just k3s-test               # deploy k3s test nodes
```

### Useful direct commands

```bash
nix eval .#evalTests --show-trace --print-build-logs --verbose
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
nixos-rebuild switch --flake .#<hostname>
```

## Test Structure and Expectations

Eval tests live under:

- `outputs/x86_64-linux/tests/`
- `outputs/aarch64-linux/tests/`
- `outputs/aarch64-darwin/tests/`

Typical test pair:

- `expr.nix`
- `expected.nix`

Agent expectations:

- If logic changes affect shared modules, run `just test`.
- If only docs/comments changed, tests may be skipped, but say so explicitly.
- If tests cannot run, report why and include the exact failing command.

## Formatting and Style

### Formatting tools

- Nix: `nixfmt` (RFC style, width 100)
- Non-Nix: `prettier` (see `.prettierrc.yaml`)
- Spelling: `typos` (see `.typos.toml`)

### Nix style conventions

- Files use `kebab-case.nix`.
- Prefer `inherit (...)` for attribute imports.
- Prefer `lib.mkIf`, `lib.optional`, `lib.optionals` for conditional config.
- Use `lib.mkDefault` for defaults and `lib.mkForce` only when necessary.
- Keep module options documented with `description`.

Module pattern:

```nix
{ lib, config, ... }:
{
  options.myFeature = {
    enable = lib.mkEnableOption "my feature";
  };

  config = lib.mkIf config.myFeature.enable {
    # ...
  };
}
```

## Platform Notes

- `Justfile` uses `nu` (`set shell := ["nu", "-c"]`).
- Some tasks exist only on Linux or macOS via `[linux]` / `[macos]` guards.
- `just local` has different implementations per platform:
  - Linux: `nixos-switch`
  - macOS: `darwin-build` + `darwin-switch`

## Secrets and Safety

- Secrets are managed with agenix and an external private secrets repo.
- Never inline secret values in Nix files, tests, or docs.
- Do not run broad remote deploy commands unless requested.
- Prefer build/eval validation first, deploy second.

## Change Review Checklist (for agents)

Before finishing, verify:

1. Change is scoped to requested behavior.
2. `just fmt` applied (or not needed, stated explicitly).
3. `just test` run for config changes (or limitation explained).
4. No secrets or machine-specific artifacts added.
5. User-facing summary includes what changed and what was validated.

## Common Pitfalls

- Editing host-specific files when the change belongs in shared module layers (`modules/` or
  `home/`).
- Forgetting to update both Linux and darwin paths when touching shared abstractions.
- Running deployment commands to validate syntax when `nix eval`/`nix build` would be safer.
- Introducing hardcoded usernames/paths instead of using `myvars` and existing abstractions.

## References

- [README.md](./README.md)
- [Justfile](./Justfile)
- [outputs/README.md](./outputs/README.md)
- [hosts/README.md](./hosts/README.md)
- [home/README.md](./home/README.md)
- [modules/README.md](./modules/README.md)
- [secrets/README.md](./secrets/README.md)
