---
name: nix-config-secrets
description:
  Use when adding, changing, renaming, or removing an agenix secret, deciding whether a secret
  belongs to agenix or to the encrypted dotfiles sync, wiring a secret into a host, or fixing a
  decryption or activation failure in this repo.
---

# Working with secrets

Secrets are age-encrypted files in the private repository `~/codes/nix-secrets`
(`git@github.com:ryan4yin/nix-secrets.git`), pulled in as the `mysecrets` flake input and declared
here in `secrets/nixos.nix` and `secrets/darwin.nix`. No secret value or ciphertext is ever stored
in this public repository.

Read [secrets/README.md](../../../secrets/README.md) for the concepts and the recipient rule.

## Which flow a file belongs to

Two age flows live in `~/codes/nix-secrets`, and a file belongs to exactly one.

| Flow                            | Shape                                                          | Consumed as                                              | `flake.lock` bump |
| ------------------------------- | -------------------------------------------------------------- | -------------------------------------------------------- | ----------------- |
| **agenix** (`secrets.nix`)      | static and one-way: repository → host, decrypted at activation | `/run/agenix/<name>` or an `environment.etc` copy        | yes               |
| **dotfiles sync** (`dotfiles/`) | changes on the host; `save`/`restore` are manual, outside Nix  | a real file under `$HOME`, edited by hand or by its tool | **no**            |

agenix is for the secrets that barely change and that a Nix module or service reads from the
decrypted path. Everything else is a synced dotfile: Nix does not read it, it changes often, or it
is a config file its tool keeps rewriting that happens to carry a few secrets inside. The pin
decides it, not the encryption: `flake.lock` fixes the agenix revision, so every edit costs a
rebuild and switch on every desktop.

Nothing in this flake evaluates the sync flow: no `secrets.nix` entry, no `agenix -r`, no lock bump,
so the three-step order in §2 does not apply to it. Its manifest and file list live in
`~/codes/nix-secrets/dotfiles/`; this repository carries the pointer, never the inventory. Do not
list synced paths here or copy one into a Nix module. The flow covers the desktops only; do not set
it up on a server or a cluster node.

`nushell-secrets.nu` already moved to `~/.secrets/nushell-secrets.nu`. It has no agenix entry and
must not get one back.

## Core rules

1. **Never read a decrypted secret.** Reference its path; do not `cat`, copy, or print it. Prove a
   change with metadata (mode, owner, timestamps), never with content. The same holds for a file the
   sync flow owns: it is a live credential under `$HOME`, and its path is listed in the private
   repository, not here.
2. **Three steps, in order.** The private repository changes first, then this repository's
   `flake.lock` moves `mysecrets` to that commit, then the declaration and consumer change here.
   `file = "${mysecrets}/x.age"` resolves against the locked revision, so a declaration that lands
   before the lock bump points at a file that does not exist yet.
3. **Every secret stays decryptable by the desktops.** A recipient set is
   `desktop_keys ++ <the hosts that need it>`; `recovery_key` is a member of `desktop_keys`. The one
   exception is `restic-password-desktop.age`, readable by `desktop_keys` alone.
4. **A consumer sits behind the same gate as its secret.** A secret declared under
   `modules.secrets.desktop` only exists on desktops, so only a desktop-gated module may reference
   it. Desktops and servers are mutually exclusive: `secrets/nixos.nix` asserts that a host never
   enables `desktop` together with a server group, so a value both sides need takes a deliberate
   choice rather than enabling both groups.
5. **Least privilege on the decrypted file.** Pick the narrowest mode that works, and set the owner
   together with the mode.

## 1. Where the pieces live

| Piece                                         | Location                                                                                       |
| --------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Recipient list, encrypted files, `agenix` CLI | `~/codes/nix-secrets` (private; `git@github.com:ryan4yin/nix-secrets.git`)                     |
| The pinned revision of that repository        | `flake.lock`, input `mysecrets`                                                                |
| Declaration: file, mode/owner, `/etc` copy    | `secrets/nixos.nix`, `secrets/darwin.nix`                                                      |
| Which host gets which group                   | `modules.secrets.<group>.enable` in `outputs/<system>/src/<name>.nix` or a host module         |
| Consumers                                     | modules reading `config.age.secrets."<name>".path` (default `/run/agenix/<name>`)              |
| Decryption key                                | `age.identityPaths`: the host's SSH host key; `/persistent/etc/ssh/...` on a preservation host |
| Secret-bearing dotfiles edited in place       | `~/codes/nix-secrets/dotfiles/` — private, not a flake input, no entry in `secrets.nix`        |

The private repository keeps its `.age` files in `desktop/` (only desktops decrypt them), `server/`
(any server), and `certs/`; `public/` holds publishable plaintext, not `.age`.

## 2. Add or change a secret

Do the mechanical work yourself: edit `secrets.nix` in `~/codes/nix-secrets`, run the
non-interactive steps, bump the lock, and add the declaration and consumer. For a new secret, or a
full replacement, pipe the plaintext into the `replace` recipe: it removes the target first, so
agenix only encrypts and needs no `sudo`. Hand back only what needs a human: the partial `edit` and
the `rekey` recipes in [`secrets/Justfile`](../../../secrets/Justfile) (they decrypt the current
value, so they handle key material, `$EDITOR`, and `sudo`) and anything else under `sudo`. Commits
and pushes follow the global git rules.

1. In `~/codes/nix-secrets`, add the file under `desktop/` or `server/` with a matching
   `secrets.nix` entry, keyed by that exact path (e.g. `"./desktop/xxx.age"`), and the recipient set
   from core rule 3. Then encrypt it with the `replace` recipe (§3); ask the user only when the
   plaintext has to come from an interactive session.
2. Here: `just upp mysecrets` (commits the lock) or `nix flake update mysecrets` (leaves it for you
   to commit). `git diff flake.lock` should show only `mysecrets` moving.
3. Declare it in `secrets/nixos.nix` or `secrets/darwin.nix` under the right
   `modules.secrets.<group>` gate, with a mode/owner preset (§4).
4. Point the consumer at the runtime path, from a module behind the same gate (core rule 4).
5. `just test` and `just build-host <host>`, deploy, then verify as in §5.

Changing only a secret's value is steps 1, 2, and the deploy: use `replace` for a full replacement
(the agent can run it) or `edit` for a partial change (needs the host key).

## 3. The private repository

The agenix operations run against `~/codes/nix-secrets`. Their single source is
[`secrets/Justfile`](../../../secrets/Justfile), which pins the identity, option order, and
`$EDITOR`; run them from this repository's root and keep each path identical to its key in
`secrets.nix`:

```bash
just -f secrets/Justfile replace ./desktop/xxx.age < plaintext   # add or fully replace (no sudo)
just -f secrets/Justfile edit ./desktop/xxx.age                  # partial edit (sudo, $EDITOR)
just -f secrets/Justfile rekey                                   # re-encrypt after a recipient change
```

`edit` and `rekey` decrypt the current value with the host key, so they need `sudo`; `replace` only
encrypts to the recipients in `secrets.nix`, so it needs no `sudo`. `edit` passes `EDITOR=hx` to the
root `agenix` process, because `sudo` resets the environment and the invoking user's `EDITOR` would
not reach it; do not add `sudo -E` or set `EDITOR` yourself.

## 4. Modes and ownership

Use one of the presets in `secrets/nixos.nix` (`noaccess`, `high_security`, `user_readable`); the
table and the `environment.etc` copy trap are in
[secrets/README.md](../../../secrets/README.md#decrypted-file-permissions). The rule to remember:
**whenever an `environment.etc` entry sets `mode`, it also sets `user`.** Never widen a mode to make
a root-owned copy readable.

## 5. Verify without reading

```bash
stat -c '%a %U:%G' /run/agenix/<name>    # mode and owner, not content (the default path)
ls -l /run/agenix/                       # /etc/agenix/ holds only the environment.etc copies
journalctl -b | grep -5 agenix                                  # NixOS
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stderr.log  # macOS
```

A successful activation is silent. Check that the _access_ changed as intended (the mode and owner
you set, an old copy gone) instead of assuming activation did it.

## 6. Remove or rename a secret

- Search all references before changing it:

  ```bash
  grep -Rni '<secret-name>' --include='*.nix' --include='*.toml' .
  ```

  Check `secrets/`, `home/`, `modules/`, `hosts/`, outputs, tests, and the private repository.

- Delete the `age.secrets` entry, its `environment.etc` placement, and every consumer in one change;
  a declaration whose file no longer exists breaks activation. On darwin also drop the path from the
  `chown`/`chmod` list in `system.activationScripts.postActivation`.
- Remove it from `secrets.nix` and delete the file in the private repository, then bump the lock.
- A rename changes the attribute name and every consumer. The `.age` filename is separate.
- Moving a secret **out** of agenix into the sync flow is that deletion plus what agenix used to
  guarantee: the consumer points at a `$HOME` path, and on a preservation host the directory joins
  `preservation.preserveAt`, which also sets its mode. A sourced file that may be missing is left to
  fail: nushell has no conditional `source`
  ([nushell#8214](https://github.com/nushell/nushell/issues/8214)), and a host without the file is
  misconfigured, not half-working.

## 7. Failure modes

- **Decryption fails on one host:** its host key is not a recipient. Add its
  `/etc/ssh/ssh_host_ed25519_key.pub` to `secrets.nix`, rekey (§3), push, bump the lock, redeploy.
- **Eval or activation cannot find the file:** the lock still points at a `mysecrets` revision
  without it (core rule 2).
- **`permission denied` in a user service:** it reads a root-only secret. Fix that secret's owner;
  do not widen the mode.
- **A preservation host cannot decrypt at boot:** `age.identityPaths` must use the
  `/persistent/etc/ssh/...` path, which exists before preservation mounts `/etc`.
- **The first macOS activation fails** on the `/etc/agenix` copies, because they run before
  `activate-agenix` has decrypted anything. Run it again.
- **Nushell exits 1 with `File not found` and the shell has no aliases:** the sourced secret file is
  missing. agenix guaranteed the path; the sync flow does not, and the failure is left loud on
  purpose. Restore the file on that host. Never silence it with an empty placeholder: the sync tool
  reads that as a local edit and reports a conflict.
- **A secret is gone after a reboot on a desktop:** it moved out of agenix and its `$HOME` directory
  is not in `preservation.preserveAt`, so the tmpfs root drops it.
