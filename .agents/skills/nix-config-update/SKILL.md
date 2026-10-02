---
name: Nix Config Update
description:
  Use when updating flake inputs, bumping nixpkgs, or rolling an update out to hosts in this repo.
  Covers the safe update, validate, deploy, verify, and rollback procedure.
---

# Updating this flake safely

Read this before running `just up`, `just upp`, `just up-nix`, or `just override-pkgs`, and before
deploying the result to any host.

## Core rules

1. **Update and deploy are two steps.** Never fold "bump the lock file" and "switch every host" into
   one blind action.
2. **Validate before touching a host.** An update is only a candidate until `just test` is green and
   the affected hosts build locally.
3. **One reviewable commit per update.** The convention here is a `flake.lock: Update` commit for
   the bump; a config change gets its own commit or PR.
4. **Keep a way back.** Anything that reaches a host needs a rollback path: the previous generation,
   `boot` mode, `just darwin-rollback`, or `git revert`.
5. **Security first.** An update re-opens the supply chain. Re-audit every input whose revision
   moved before you deploy it.

## 1. Pre-flight

- `git status` is clean, and you are on `main` or a fresh branch for the work.
- `just test` is green _before_ the update, so you have a baseline to compare against.
- Enough disk for the new closures: `df -h /nix/store`. Broad nixpkgs bumps pull a lot.
- Know what will move and choose the narrowest recipe that does the job.

## 2. Run the update

| Goal                     | Command                     | Notes                                                                      |
| ------------------------ | --------------------------- | -------------------------------------------------------------------------- |
| Everything               | `just up`                   | Updates and commits the lock file automatically; audit before pushing      |
| One input                | `just upp <input>`          | Same, for a single input, e.g. `just upp catppuccin`; audit before pushing |
| The nixpkgs family       | `just up-nix`               | Updates `nixpkgs-stable`/`-master`/`-darwin`/`-patched`; **not `nixpkgs`** |
| Pin `nixpkgs`            | `just override-pkgs <hash>` | Pin `nixpkgs` to a known-good Hydra commit                                 |
| Update but keep it dirty | `nix flake update <input>`  | Leaves the change uncommitted so you can inspect it first                  |
| Nix itself (macOS)       | `just nix-upgrade`          | `determinate-nixd upgrade`; macOS only                                     |

After an update, read `git diff flake.lock`: it lists exactly which inputs moved and by how many
commits. Because `just up` and `just upp` commit automatically, either use
`nix flake update <input>` while auditing or amend the generated lock commit after the audit so its
message records the conclusion.

## 3. Audit the change

Treat an update as a supply-chain event, not just a version bump.

1. From `git diff flake.lock`, list every input whose `locked.rev` changed.
2. Find the inputs that contribute modules this repo imports:

   ```bash
   grep -rn "homeModules\.\|nixosModules\.\|darwinModules\." --include='*.nix' .
   ```

3. For each of those inputs, read what changed between the old and new revision in the module files
   we actually import. Look for:
   - restricted `nix.settings` (`substituters`, `extra-substituters`, `trusted-public-keys`,
     `trusted-users`) — at the Home Manager layer these are ignored for an untrusted user and only
     warn, but at the system layer they are a root-equivalent trust boundary;
   - `environment.etc` / `home.file` entries with a `mode` or `user` that widens access;
   - `system.activationScripts`, `systemd.services` running as root, sudo/polkit rules;
   - `lib.mkForce` overrides that silently replace existing settings;
   - eval-time network access or import-from-derivation.
4. For nixpkgs-class inputs, skim the lock diff and expect broken packages and eval deprecation
   warnings (see "Lessons from past updates").
5. Write the audit conclusion into the update commit message. If an automatic recipe already made
   the commit, amend it only after reviewing the diff; do not push the unaudited commit first.

## 4. Validate before deploying

Run these before any host is touched:

- `just test` — must print `true`. An exit code of `0` with `false` is a failed suite.
- `just eval-host <host>` — fast, evaluation only.
- `just build-host <host>` — builds the full system closure and catches broken packages or build
  failures that eval misses.
- `just build-microvm <guest>` — same, for a MicroVM guest.
- `nix flake check` — broader checks when the change touches shared code.

Cover every host you are about to deploy, and prefer building the closure over trusting a green
eval.

Preview what the machine you are on will actually change before it is deployed:

```bash
nix store diff-closures /run/current-system '.#nixosConfigurations.<host>.config.system.build.toplevel'
```

It lists every package whose version or size moves; an empty result means nothing changes. Read it
for unexpected removals, major-version jumps, and kernel or systemd changes that need a reboot.

## 5. Deploy in stages

Modes are `switch` (take effect now, the default) and `boot` (only the next boot). Add `debug` for
verbose output. Anything else is rejected.

Activating the machine you are on runs `nixos-rebuild --sudo` (or `sudo -E darwin-rebuild`) and
blocks on a password prompt. **An agent cannot run these; they are for the user to run by hand.**

- Current desktop: `just niri [mode] [verbosity]`
- Other local NixOS host: `just local [mode] [verbosity]`
- macOS: `just local [debug]` (build then switch; macOS has no switch/boot split)

The rest authenticate over SSH as root on the target, so they run non-interactively — but they still
change remote state. Confirm the target instead of trusting the recipe's default, then state it back
to the user and get authorization for that host:

```bash
hostname                  # which machine you are on
git branch --show-current
git remote -v
getent hosts <host>       # the address the tag will connect to
ssh root@<host> hostname  # the host that actually answers
```

- Remote servers: `just shoryu [mode]`, `just shushou`, `just youko`, `just ruby`, `just kana`
- All VM hosts at once: `just lab [mode]`; any Colmena tag: `just col <tag> [mode]`
- k3s test nodes: `just k3s-test [mode]`
- MicroVM guest: `just microvm-deploy <guest> <host> <guest-ip>` — deploy guests serially and check
  each one before moving on.

Use `boot` plus a deliberate reboot for anything that can drop networking mid-flight: the VM hosts
with the `br0` bridge, and broad nixpkgs bumps. See
[hosts/README.md](../../../hosts/README.md#deploying-vm-hosts).

## 6. Verify after deploying

- `systemctl --failed` and `just list-failed` for failed units.
- `journalctl -b -p err` for boot-time errors.
- The user-visible surface: network, the desktop session, and the specific service you changed.
- Re-run `just test` so a dirty tree cannot hide a regression.

## 7. Roll back

- NixOS: `just history` lists system generations; pick the previous one in the bootloader menu, or
  re-deploy a reverted tree.
- macOS: `just darwin-rollback` (`darwin-rebuild --rollback`).
- Remote (Colmena): `git revert <sha>` and re-apply, or apply with `boot` and reboot.
- Update failed but never deployed: drop the bump with `git checkout -- flake.lock`, then reproduce.
- Isolate a bad bump by moving one input at a time with `nix flake update <input>`, and pin a
  known-good nixpkgs with `just override-pkgs <hash>` while the breakage is fixed upstream.

## 8. Clean up only after it is stable

`just gc` (older than 7 days) and `just clean` (wipes profile history) delete the generations you
would roll back to, so run them last, once the update has proven stable. `just gcroot` only lists GC
roots. The full list of hazardous recipes is in the Command Hazards section of
[AGENTS.md](../../../AGENTS.md#command-hazards).

## Why these rules exist

- `0fe12bef fix(nix): preserve default sandbox shell` - a `nix.settings` change used
  `sandbox-paths`, which replaced Nix's compiled defaults (including the sandbox shell used for
  legacy shebangs). Use `extra-sandbox-paths`, and verify with
  `nix config show | grep sandbox-paths`.
- `125bce3b fix: cuda12.8-cuda_cudart-12.8.90 is marked as broken` and
  `78fc64e1 fix(neovim): disable nixvim manpage on broken nixpkgs pin` - broken packages after a
  nixpkgs bump are normal; `just build-host` finds them before a deploy does.
- `4bd463a7 chore(eval): resolve catppuccin and rust-overlay deprecation warnings` - input bumps
  surface deprecation warnings that become errors in a later bump.
