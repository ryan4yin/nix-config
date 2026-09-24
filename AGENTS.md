# Repository Agent Guide

This flake manages NixOS hosts, macOS via nix-darwin, shared Home Manager profiles, and Colmena
deployments. Keep repository guidance here; reusable global rules live in `agents/AGENTS.md`. See
[agents/README.md](./agents/README.md) for their scope and symlink installation targets.

## Where Changes Belong

- `flake.nix` defines inputs; `outputs/default.nix` composes outputs for `x86_64-linux`,
  `aarch64-linux`, and `aarch64-darwin`.
- `modules/` contains system modules; `home/` contains Home Manager modules. Put shared behavior
  here rather than duplicating it in host configurations.
- `hosts/` contains host-specific configuration; `outputs/<system>/src/` wires hosts into outputs.
- `vars/` and `lib/` provide shared values and helpers. Use `myvars` and existing abstractions
  instead of hardcoding usernames or paths.
- `secrets/` contains agenix definitions; secret material also comes from a private external repo.
- `overlays/` and `hardening/` hold package overlays and hardened (nixpak/bwrap) wrappers.
- Noctalia (the Wayland shell) baseline is `home/linux/gui/base/noctalia/config/config.toml`,
  symlinked out of store into `~/.config/noctalia/` so edits hot reload without a rebuild. Settings
  UI changes stay in the state layer (`~/.local/state/noctalia/settings.toml`, loads last). Host
  overrides go in a `host-<name>.toml` there (merged after `config.toml`).

## Commands and Platforms

- Prefer recipes in [Justfile](./Justfile); use `just --list` to discover available commands and
  `just --show <recipe>` to inspect behavior before running them.
- The Justfile uses Nushell. Preserve `[linux]` / `[macos]` guards and host naming conventions.
- Deploy by hostname: NixOS desktops are `<hostname>-niri` (`just niri`); other NixOS hosts, VMs,
  and macOS hosts use the bare hostname (`just local`, mapping to `nixos-switch`, or `darwin-build`
  / `darwin-switch` on macOS). Arguments differ per platform; check both when changing shared
  behavior.
- `nix develop` provides formatters and linters. If needed, `nix shell nixpkgs#just nixpkgs#nushell`
  provides the task runner and its shell.

## Validation

- For Nix changes, run `just fmt` and inspect the diff: it formats all Nix files. Nix style is
  `nixfmt` with width 100.
- For supported non-Nix files, use `prettier --write <file>` and `prettier --check <file>`;
  configuration lives in `.prettierrc.yaml`. Spelling checks use `typos` and `.typos.toml`.
- Run `just test` for configuration changes. It evaluates `.#evalTests` across Linux and Darwin; the
  output must be `true`. Exit code zero with `false` is a failed suite.
- Eval tests are `expr.nix` / `expected.nix` pairs under `outputs/<system>/tests/`. Update focused
  cases when changing behavior covered by those tests.
- Use `nix flake check` for broader flake checks. A host build can validate changes beyond eval:
  `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- Documentation-only changes need formatting checks and `git diff --check`; Nix tests may be
  skipped. Report checks run, skipped, or blocked, including the command and reason for failures.

## Nix Conventions

- Use `kebab-case.nix` filenames and `inherit (...)` for attribute imports.
- Prefer `lib.mkIf`, `lib.optional`, and `lib.optionals` for conditional configuration.
- Use `lib.mkDefault` for defaults and `lib.mkForce` only when necessary.
- Give module options a `description` and preserve platform-specific conditions.

## Command Hazards

- `just eval-host <host>`, `just build-host <host>`, `just build-microvm <guest>`, and `just test`
  evaluate or build without activating a system. Use these commands for previews and validation.
- `just up`, `just upp`, and `just up-nix` update flake inputs and commit the lock file. Use
  `nix flake update <input>` when the update should remain uncommitted.
- `just shoryu`, `just shushou`, `just youko`, `just lab`, and `just k3s-test` activate systems
  through Colmena. Use the narrower recipe that matches the intended host scope.
- `just microvm-deploy <guest> <physical-host> <guest-ip>` installs and activates one MicroVM
  guest. Deploy guests serially and check the guest Node and host services after each activation.
- VM hosts (`shoryu`, `shushou`, `youko`) carry the `br0` bridge for their guests. Use the
  `boot`-based host deployment procedure for network stack or broad nixpkgs changes; see
  [hosts/README.md](./hosts/README.md#deploying-vm-hosts).
- MicroVM state is stored in `/var/lib/microvms/<name>/{etc,var,home}.img`. Preserve these images
  when changing the guest configuration.
- `just clean`, `just gc`, `just ggc`, and `just game` remove state or rewrite history. Use them only
  for the intended cleanup or history operation.
- `just penvof` reads a process environment and can expose secrets. Use normal process inspection
  commands when environment values are not required.

## Further Context

- [Repository overview](./README.md)
- [Outputs and tests](./outputs/README.md)
- [Hosts](./hosts/README.md), [system modules](./modules/README.md), and
  [Home Manager](./home/README.md)
- [Secrets](./secrets/README.md)
