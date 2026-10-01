---
name: Nix Config Debug
description:
  Use when something in this repo is broken: an eval or build error, a failed activation, a crashed
  service, a host that will not come up, or a regression after an update. Provides the repo-specific
  triage map.
---

# Debugging this repository

Use the global `systematic-debugging` skill for the process: find the root cause before proposing a
fix, and do not paper over a symptom. This skill is the map for this repository - which layer a
failure came from, what to run, what has caused it before, and how to get back to a working system
first.

## Core rules

1. **Restore service before you investigate.** A host that is down or a session that will not start
   gets rolled back first (step 4). Debugging from a broken system is slower and riskier.
2. **Attribute the failure before fixing it.** Confirm which layer failed, and whether the cause is
   your working tree or the last update. A guessed fix costs more than the check.
3. **Never make a check pass by weakening it.** Do not disable a test, drop a security assertion, or
   `mkForce` over the failing value to get green.
4. **Keep the tree clean while debugging.** One untracked experiment makes every result ambiguous.
5. **Diagnose read-only.** Know which commands destroy the evidence you will want in step 4.

## 1. Classify the failure

| Symptom                                                  | Layer      | First command                                                                                            |
| -------------------------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------- |
| `just test` is `false`, eval error, "infinite recursion" | eval       | `just test`, `just eval-host <host>`                                                                     |
| Build error, missing hash, "marked as broken"            | build      | `just build-host <host>`, `just build-microvm <guest>`                                                   |
| The switch itself fails, activation script error         | activation | the deploy output; `just history` to see what is live now                                                |
| A unit is dead or restarting                             | runtime    | `just list-failed`, `systemctl status <unit>`, `journalctl -u <unit>`                                    |
| Boot-time errors, no login, wrong kernel                 | runtime    | `journalctl -b -p err`, `just history`, boot the previous generation                                     |
| The desktop or a GUI app misbehaves                      | session    | `journalctl --user -b -p err`; see the `nix-config-desktop` skill                                        |
| A VM or guest is unreachable                             | network    | `br0` and the VM taps on the VM host; see [hosts/README.md](../../../hosts/README.md#deploying-vm-hosts) |
| A secret is missing or unreadable                        | secrets    | see the `nix-config-secrets` skill                                                                       |

## 2. Localize

- **eval** - `just test` evaluates every host, so its error names the file that broke. Option
  renames are the single most common cause (NixOS and Home Manager move options between releases),
  and the error usually quotes the old name. `nix flake check` widens the net.
- **build** - `just build-host <host>` builds the closure. `nix log <drv>` shows the failing build;
  "marked as broken" and a hash mismatch are both normal after a nixpkgs bump.
- **activation** - the deploy command prints the activation error. These are runtime conditionals,
  so eval and build both passed. On macOS the activation logs are separate:
  `tail -n 100 /Library/Logs/org.nixos.activate-agenix.stderr.log` for agenix, and the
  `darwin-rebuild` output for the rest.
- **runtime** - `just list-failed` for failed units, `systemctl status <unit>` for the exit reason,
  `journalctl -u <unit> -n 100` for its log, `journalctl -b -p err` for the whole boot.
- **flake plumbing** - `nix flake metadata`, `nix flake check`, and `git diff flake.lock`.

## 3. Is it your change or the update?

```bash
git status                      # is the tree dirty?
git log --oneline -5 -- flake.lock
git diff flake.lock             # which inputs moved
```

- Move one input at a time to isolate it: `nix flake update <input>` (uncommitted) or
  `just upp <input>` (committed).
- Drop a bad bump without touching your work: `git checkout -- flake.lock`, then reproduce.
- `nix flake update --override-input nixpkgs github:NixOS/nixpkgs/<hash>` pins a known-good commit
  (`just override-pkgs <hash>` is the wrapped version).

## 4. Restore service first

- NixOS: `just history` lists system generations; pick the previous one in the bootloader, or
  re-deploy the reverted tree. A generation that still works is a better place to debug from.
- macOS: `just darwin-rollback`.
- Remote host: `git revert <sha>` and re-apply, or apply the last-good revision with `boot`.
- A host that is already unreachable: the bootloader menu is the only lever, so prefer `boot` plus a
  reboot for network-stack changes in the first place (see the `nix-config-update` skill).

## 5. Fix and prove it

- Fix the root cause, then re-run the _same_ command that failed, plus `just test`.
- Deploy through a validation step, not straight to the target: `just eval-host`, `just build-host`,
  then the deploy recipe.
- State the evidence. "It builds and the unit is active" is a result; "the change looks right" is
  not.

## 6. What usually breaks

Fix commits over this repository's history, by surface (keyword-matched, so approximate) - useful as
a prior when a symptom is vague:

| Surface                  | Count | Examples                                                     |
| ------------------------ | ----- | ------------------------------------------------------------ |
| Desktop / Wayland        | 81    | portal race at login; noctalia OSD/bar layout; idle and lock |
| darwin / macOS           | 68    | Home Manager activation; launchd; platform-only options      |
| Build / package / cache  | 41    | broken package after a bump; stale source hash               |
| Boot / kernel / hardware | 39    | resume from suspend; firmware; kernel params                 |
| Network / firewall       | 34    | VM host bridging; per-service network namespaces             |
| k8s / infra services     | 31    | advertised DNS; workload placement after a host change       |
| Eval / option names      | 26    | renamed or deprecated options                                |
| secrets / agenix         | 21    | recipient set; file mode and owner                           |
| activation / systemd     | 21    | uid/gid drift; unit dependencies                             |
| Home Manager             | 16    | `useGlobalPkgs`; XDG paths                                   |

## 7. Read-only tools, and the ones that destroy evidence

Safe: `just history`, `just gcroot`, `just list-failed`, `just verify-store`, `journalctl`,
`systemctl status`, `nix log`, `nix store diff-closures <old> <new>`.

- `just clean`, `just gc`, `just ggc`, `just game` - delete or rewrite the generations and commits
  you would roll back to. Never while debugging.
- `just penvof <pid>` - prints a process environment, which can contain secrets.
- `just repair-store <path>` and `nix store delete` - mutating, last resort, and they change the
  store underneath a running system.

## Lessons from past changes

These all happened in this repository; they are the reason for the steps above.

- `5ee8b728 fix(restic): use the correct systemd timer option names (#319)` and
  `54016a9d fix: address nixpkgs rename/deprecation warnings` - option renames are the most common
  eval break, and the error message tells you the replacement.
- `7cba098b fix(home): replace deprecated stdenv.is* with hostPlatform.is*` - a rename can be loud
  and still not fail the build; read the warnings.
- `9315055b fix(darwin): unblock home-manager activation` - activation failures are invisible to
  eval and build, so a green `just test` says nothing about them.
- `c6bbb69b fix(shoukei): muvm failed to build currently` and
  `424b000a fix: disable heroic - failed to build` - broken packages after a bump; `just build-host`
  finds them before a deploy does.
- `9aa0ff80 feat: update flake.lock fix: issues introduced by the update` - one bump both skipped an
  update and changed a flag's name, which is why updates and fixes stay in separate steps.
- `77e31bd4 fix(idols-ai): keep network config across S3 resume` and
  `ce164561 fix(youko): mitigate the flaky USB-SATA HDD bridge` - some failures are hardware, and
  the fix is a workaround with a comment explaining why.
- `688a244a fix(k3s): ignore advertised DNS on test VMs` - a VM inherits the host's networking, so
  check the host when the guest looks wrong.
