---
name: nix-config-debug
description: >-
  Use when something here is broken or stops working: an eval or build error, a failed activation, a
  dead or restarting unit, a mihomo or DNS outage, an unreachable host or MicroVM guest, or a
  failing CI action.
---

# Debugging this repository

Follow the global `systematic-debugging` skill for the process (root cause before any fix). This
skill is only the map: which layer failed, and where to look. Rolling back, isolating a bad input
bump, and the commands that destroy rollback points are in the `nix-config-update` skill.

## Core rules

1. **Restore service first.** A down host or a dead session gets the previous generation before any
   investigation. Rolling back the machine you are on needs `sudo`, so the user does it.
2. **Name the layer before touching code.** Eval, build, activation, and runtime failures have
   different causes; a green `just test` says nothing about activation.
3. **Never get to green by weakening a check**: no disabled test, dropped assertion, or `mkForce`
   over the failing value.
4. **Preserve existing user changes.** Do not discard or stash them without authorization. If a
   clean baseline is needed, record the current diff and ask before isolating it.

## 1. Localize by layer

| Layer         | Symptom                                                          | Look with                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------- | ---------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| eval          | `just test` fails, an eval error                                 | `just eval-host <host>` (already passes `--show-trace`)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| build         | build error, hash mismatch, "marked as broken"                   | `just build-host <host>`, then `nix log <drv>`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| activation    | the deploy fails after building                                  | the deploy output; `journalctl -u home-manager-$USER -b` for Home Manager                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| runtime       | a unit is failed or restarting                                   | `just list-failed`, `systemctl status <unit>`, `journalctl -u <unit> -b`                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| proxy/DNS     | proxied sites time out, or DNS still resolves after mihomo stops | `dig +short <site>` must return a fake-ip (`198.18.x.x`); a real IP means the resolver bypasses `dns-hijack`; on `ai` the `resolvectl dns`/`revert` hook in `hosts/idols-ai/default.nix` ties link DNS to mihomo's lifecycle and other mihomo hosts have no such hook, so read `resolvectl status` before concluding; a statically set link DNS would outlive a dead mihomo. Config and gotchas: [mihomo README](../../../modules/nixos/desktop/networking/mihomo/README.md); regenerate with `just mihomo-gen`, then restart `mihomo.service` |
| boot          | errors at boot, wrong kernel                                     | `journalctl -b -p err`; `just history` for what is booted                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| session       | desktop or app misbehaves                                        | `journalctl --user -b -p err`; the `nix-config-desktop` skill                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| remote host   | anything on a Colmena host                                       | `ssh root@<host> journalctl -b -p err`, same commands over SSH                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| MicroVM guest | guest down or unreachable                                        | on the VM host: `systemctl status microvm@<guest>` and `microvm-tap-interfaces@<guest>`; then `br0`                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| secrets       | missing or unreadable `/run/agenix/<name>`                       | the `nix-config-secrets` skill                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| shell         | nushell exits 1 with `File not found`                            | whether `~/.secrets/` exists on the host; the `nix-config-secrets` skill                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| CI            | a GitHub Action keeps failing                                    | `gh run list --workflow <wf>`, `gh run view <run> --log-failed`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |

## 2. Read the evaluated value

When `just test` fails, re-run the suite directly to get the trace (`nix eval` exits 0 even when the
suite returns `false`, so read its output):

```bash
nix eval .#evalTests --show-trace
```

The trace names the failing test under `outputs/<system>/tests/<name>/`. Read its `expr.nix` and
`expected.nix`, and evaluate the expression to see what actually came out before changing anything.

Most eval-layer questions are "what did this option actually end up as?". Ask the configuration
directly instead of reading modules:

```bash
nix eval .#nixosConfigurations.<host>.config.<option.path>
nix eval .#nixosConfigurations.<host>.config.systemd.services \
  --apply 's: builtins.filter (n: builtins.match "microvm.*" n != null) (builtins.attrNames s)'
nix repl   # then `:lf .` and inspect nixosConfigurations.<host>.config
```

Renamed or removed options are the most common eval break after an update; the error or warning
names the replacement. Treat deprecation warnings as failures waiting to happen.

## 3. Your change or the update?

`git status`, `git log --oneline -5 -- flake.lock`, and `git diff flake.lock` tell you which. If the
lock moved, isolate the input as described in the `nix-config-update` skill before reading code.
Preserve unrelated working-tree changes; do not use `git checkout`, `git stash`, or cleanup commands
to manufacture a clean tree without authorization.

## 4. Prove the fix

Re-run the exact command that failed, then `just test`, then `just build-host <host>` for every
affected host before anyone deploys. For a running service, confirm the live config is the one just
generated (service activation time against the file's mtime) and restart if they differ. Report the
evidence ("the unit is active, `just test` is `true`"), not the intent.
