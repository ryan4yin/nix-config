# Repository Agent Guide

This flake manages NixOS hosts, macOS via nix-darwin, shared Home Manager profiles, and Colmena
deployments. Keep repository guidance here; the global rules and global skills shared across
projects live in [agents/](./agents/README.md).

## Where Changes Belong

- `flake.nix` defines inputs; `outputs/default.nix` composes outputs for `x86_64-linux`,
  `aarch64-linux`, and `aarch64-darwin`.
- `modules/` contains system modules; `home/` contains Home Manager modules. Put shared behavior
  here rather than duplicating it in host configurations.
- `hosts/` contains host-specific configuration; `outputs/<system>/src/` wires hosts into outputs.
- `vars/` and `lib/` provide shared values and helpers. Use `myvars` and existing abstractions
  instead of hardcoding usernames or paths.
- `secrets/` contains agenix definitions. The encrypted `.age` files live in the private
  `~/codes/nix-secrets` repository, never in this public one — never copy a `.age` file here. Use
  the `nix-config-secrets` skill.
- `overlays/` and `hardening/` hold package overlays and hardened (nixpak/bwrap) wrappers.
- Desktop (Niri and Noctalia) config is mostly out-of-store symlinks that hot-reload without a
  rebuild; use the `nix-config-desktop` skill before changing it.

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
- Run `just test` for configuration changes; it evaluates `.#evalTests` across Linux and Darwin and
  exits non-zero unless the result is `true`. The bare `nix eval .#evalTests` exits 0 even on
  `false`, so run `just test` or compare its `--json` output yourself.
- Eval tests are `expr.nix` / `expected.nix` pairs under `outputs/<system>/tests/`. Update focused
  cases when changing behavior covered by those tests.
- Use `nix flake check` for broader flake checks. A host build can validate changes beyond eval:
  `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- Documentation-only changes need formatting checks and `git diff --check`; Nix tests may be
  skipped. Report checks run, skipped, or blocked, including the command and reason for failures.

## Nix Conventions

- Before a non-trivial change, find how nixpkgs (or the upstream project) already does it and follow
  that shape instead of inventing a local convention. This covers a new package or overlay, a
  hardening wrapper, a systemd unit, a kernel or driver option, and a version bump that changes the
  build inputs. Look at the by-name siblings under `pkgs/by-name/<xx>/<name>/`, the recent history
  of the file you are changing, and the upstream contributing docs.
- Use `kebab-case.nix` filenames and `inherit (...)` for attribute imports.
- Prefer `lib.mkIf`, `lib.optional`, and `lib.optionals` for conditional configuration.
- Use `lib.mkDefault` for defaults and `lib.mkForce` only when necessary.
- Give module options a `description` and preserve platform-specific conditions.

## Security

Security architecture, control limitations, rollout checks, and prioritized work are documented in
[SECURITY.md](./SECURITY.md). Keep it consistent with changes to security boundaries or defaults.

## Workarounds

Temporary workarounds, version pins, carried patches, and known gaps are recorded in
[WORKAROUNDS.md](./WORKAROUNDS.md), each with a removal condition. Add a row in the same change that
introduces one, and re-evaluate entries when their `Revisit` trigger comes up.

## Command Hazards

- `just eval-host <host>`, `just build-host <host>`, `just build-microvm <guest>`, and `just test`
  evaluate or build without activating a system. Use these commands for previews and validation.
- `just up`, `just upp`, `just up-nix`, and `just override-pkgs <hash>` update flake inputs and
  commit the lock file. Use `nix flake update <input>` when the update should remain uncommitted.
- `just niri` and `just local` activate the machine you are on through `sudo` and block on a
  password prompt; `just darwin-rollback` switches the macOS generation on the machine you are on,
  and a bare `sudo systemctl restart <unit>` activates a running service the same way. The user runs
  these, not an agent.
- `just shoryu`, `just shushou`, `just youko`, `just ruby`, `just kana`, `just lab`,
  `just k3s-test`, and `just col <tag>` activate systems through Colmena. Use the narrower recipe
  that matches the intended host scope.
- `just microvm-deploy <guest> <physical-host>` installs one MicroVM guest's runner on the physical
  host and restarts its unit there. A later host activation re-points the guest at the runner baked
  into the host's system; see WA-026 in [WORKAROUNDS.md](./WORKAROUNDS.md) before deploying. Deploy
  guests serially and check the guest Node and host services after each activation.
- VM hosts (`shoryu`, `shushou`, `youko`) carry the `br0` bridge for their guests. Use the
  `boot`-based host deployment procedure for network stack or broad nixpkgs changes; see
  [hosts/README.md](./hosts/README.md#deploying-vm-hosts).
- MicroVM state is stored in `/var/lib/microvms/<name>/{etc,var,home}.img`. Preserve these images
  when changing the guest configuration.
- `just clean`, `just gc`, `just ggc`, and `just game` remove state or rewrite history. Use them
  only for the intended cleanup or history operation.
- `just penvof` reads a process environment and can expose secrets. Use normal process inspection
  commands when environment values are not required.

## Task Skills

Repo-scoped task procedures live in `.agents/skills/` (leading dot; agents discover them and list
them in their skill catalog). `agents/` without the dot holds the global rules and skills.

## Related Repositories

When a change here affects one of these, make both edits in the same task, one branch or PR per
repository, and cross-link them — no need to be told.

- `~/codes/k8s-gitops` — Flux cluster state for the k3s cluster whose hosts are defined in
  `hosts/k8s` and `hosts/12kingdoms-youko` (NFS golden store, kube-vip block, `br0`). Host
  networking, VM images, or cluster addons usually change both repositories together.
- `~/codes/containers` — container images consumed by k8s-gitops; a tag bump is often a two-repo
  change.
- `~/codes/nix-secrets` — the private agenix store behind `secrets/` and the `mysecrets` input:
  ciphertext and recipient rules for the secrets declared here.
- `wallpapers`, `nur-ryan4yin`, `pyclipsync`, `nu_scripts`, `mattpocock-skills`, `i-have-adhd` —
  flake inputs from the user's own repositories; bump with `just upp <input>` after their source
  changes, do not edit them from here.

## Further Context

- [Repository overview](./README.md)
- [Workarounds & known gaps](./WORKAROUNDS.md)
- [Outputs and tests](./outputs/README.md)
- [Hosts](./hosts/README.md), [system modules](./modules/README.md), and
  [Home Manager](./home/README.md)
- [Secrets](./secrets/README.md), [backups](./BACKUP.md), and
  [hardened app wrappers](./hardening/README.md)
- [Installing NixOS from the ISO](./nixos-installer/README.md)
