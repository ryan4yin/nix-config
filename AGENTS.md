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

- `just up`, `just upp`, and `just up-nix` use `--commit-lock-file`. When a commit is not
  authorized, use `nix flake update <input>` for a scoped input update without committing.
- Deployment and upload recipes change systems; use eval/build commands for validation. Remote
  deployment requires an explicit request. When deployment behavior changes, report the exact `just`
  command to run.
- VM hosts (`shoryu`/`shushou`/`youko`): avoid mid-flight restarts of the network
  stack (`systemd-networkd` / the `br0` bridge) — that can drop the VM network. Use `boot` + serial
  reboot for networking or nixpkgs changes. See
  [hosts/README.md](./hosts/README.md#deploying-vm-hosts).
- `just clean`, `just gc`, `just ggc`, and `just game` remove history or amend commits; they are not
  validation steps and require explicit authorization for their target and scope.
- Do not use `just penvof` for process inspection: it can expose secret values.
- MicroVM guests (`k3s-test-1-master-*`) keep their state in
  `/var/lib/microvms/<name>/{etc,var,home}.img` on their host. Deleting or recreating an image loses
  the node's identity and cluster state; to resize one, stop the guest and grow the image in place
  (`truncate` + `e2fsck -f` + `resize2fs`) rather than re-creating it.

## Further Context

- [Repository overview](./README.md)
- [Outputs and tests](./outputs/README.md)
- [Hosts](./hosts/README.md), [system modules](./modules/README.md), and
  [Home Manager](./home/README.md)
- [Secrets](./secrets/README.md)
