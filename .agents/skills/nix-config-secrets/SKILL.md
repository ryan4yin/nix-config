---
name: Nix Config Secrets
description:
  Use when adding, changing, renaming, or removing an agenix secret, wiring one into a host, or
  fixing a decryption or activation failure in this repo.
---

# Working with secrets

Secrets are age-encrypted files in a separate private repository (`nix-secrets`), pulled in as the
`mysecrets` flake input and declared here in `secrets/nixos.nix` and `secrets/darwin.nix`. No secret
value is ever stored in this repository.

Read [secrets/README.md](../../../secrets/README.md) for the private-repository workflow and the
recipient rule. This skill covers the change end to end and the traps.

## Core rules

1. **Never read a decrypted secret.** Reference its path; do not `cat`, copy, or print it. Prove a
   change with metadata (mode, owner, timestamps), never with content.
2. **Three steps, in order.** The private repository changes first, then this repository's
   `flake.lock` moves `mysecrets` to that commit, then the declaration and consumer change here.
   `file = "${mysecrets}/x.age"` resolves against the locked revision, so a declaration that lands
   before the lock bump points at a file that does not exist yet.
3. **Every secret stays decryptable by the desktops.** A recipient set is
   `desktop_keys ++ <the hosts that need it>`; `recovery_key` is a member of `desktop_keys`. The one
   exception is `restic-password-desktop.age`, readable by `desktop_keys` alone.
4. **A consumer sits behind the same gate as its secret.** A secret declared under
   `modules.secrets.desktop` only exists on desktops, so only a desktop-gated module may reference
   it.
5. **Least privilege on the decrypted file.** Pick the narrowest mode that works, and set the owner
   together with the mode.

## 1. Where the pieces live

| Piece                                         | Location                                                                                       |
| --------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Recipient list, encrypted files, `agenix` CLI | the private `nix-secrets` repository                                                           |
| The pinned revision of that repository        | `flake.lock`, input `mysecrets`                                                                |
| Declaration: file, mode/owner, `/etc` copy    | `secrets/nixos.nix`, `secrets/darwin.nix`                                                      |
| Which host gets which group                   | `modules.secrets.<group>.enable` in `outputs/<system>/src/<name>.nix` or a host module         |
| Consumers                                     | modules reading `/etc/agenix/<name>` or `config.age.secrets."<name>".path`                     |
| Decryption key                                | `age.identityPaths`: the host's SSH host key; `/persistent/etc/ssh/...` on a preservation host |

## 2. Add or change a secret

1. In the private repository, on a desktop: add the file to `secrets.nix` with the recipient set
   from core rule 3, create or edit it with
   `sudo agenix -e ./xxx.age -i /etc/ssh/ssh_host_ed25519_key`, commit, and push.
2. Here: `just upp mysecrets` (commits the lock) or `nix flake update mysecrets` (leaves it for you
   to commit). `git diff flake.lock` should show only `mysecrets` moving.
3. Declare it in `secrets/nixos.nix` or `secrets/darwin.nix` under the right
   `modules.secrets.<group>` gate, with a mode/owner preset (step 3).
4. Point the consumer at the runtime path, from a module behind the same gate (core rule 4).
5. `just test` and `just build-host <host>`, deploy, then verify as in step 4.

Changing only a secret's value is steps 1, 2, and the deploy.

## 3. Modes and ownership

Reuse the presets defined in `secrets/nixos.nix`:

| Preset          | Mode / owner    | Use for                                          |
| --------------- | --------------- | ------------------------------------------------ |
| `noaccess`      | `0000` root     | a file nothing reads directly                    |
| `high_security` | `0500` root     | root-only consumers (services, activation)       |
| `user_readable` | `0500` `<user>` | anything a Home Manager module or the user reads |

The trap is `environment.etc."agenix/<name>"`. Setting `mode` makes it **copy** the secret instead
of symlinking it, and the copy is owned by root unless `user` is set too. Widening the mode so the
user can read a root-owned copy makes it readable by every local account; that is how
`nushell-secrets.nu` once shipped as a world-readable `0644` copy. Set `user` whenever you set
`mode`:

```nix
"agenix/nushell-secrets.nu" = {
  source = config.age.secrets."nushell-secrets.nu".path;
  mode = "0400";
  user = myvars.username;
};
```

nix-darwin ignores `mode`/`user` on `environment.etc`; `secrets/darwin.nix` chowns `/etc/agenix/*`
in a post-activation script instead.

## 4. Verify without reading

```bash
stat -c '%a %U:%G' /etc/agenix/<name>    # mode and owner, not content
ls -l /etc/agenix/
journalctl -b | grep -5 agenix                                  # NixOS
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stderr.log  # macOS
```

A successful activation is silent. Check that the _access_ changed as intended (the mode and owner
you set, an old copy gone) instead of assuming activation did it.

## 5. Remove or rename a secret

- Delete the `age.secrets` entry, its `environment.etc` placement, and every consumer in one change;
  a declaration whose file no longer exists breaks activation.
- Remove it from `secrets.nix` and delete the file in the private repository, then bump the lock.
- A rename changes the attribute name and every consumer. The `.age` filename is separate.

## 6. Failure modes

- **Decryption fails on one host:** its host key is not a recipient. Add its
  `/etc/ssh/ssh_host_ed25519_key.pub` to `secrets.nix`, rekey with
  `sudo agenix -r -i /etc/ssh/ssh_host_ed25519_key` on a desktop, push, bump the lock, redeploy.
- **Eval or activation cannot find the file:** the lock still points at a `mysecrets` revision
  without it (core rule 2).
- **`permission denied` in a user service:** it reads a root-only secret. Fix that secret's owner;
  do not widen the mode.
- **A preservation host cannot decrypt at boot:** `age.identityPaths` must use the
  `/persistent/etc/ssh/...` path, which exists before preservation mounts `/etc`.
- **The first macOS activation fails** on the `/etc/agenix` copies, because they run before
  `activate-agenix` has decrypted anything. Run it again.

## Why these rules exist

- `4909f635 security: scope privileges and stop a world-readable secret copy (#335)` - the
  `environment.etc` copy trap in step 3.
- `c8e76cef fix(darwin): agenix - remove non-exist secret` - a declaration left behind after its
  file was deleted.
- `4211d18a` - a shared `modules/nixos/base` module included `nix-access-tokens`, which not every
  host had; the reference moved to `modules/nixos/desktop/nix.nix` (core rule 4).
- `260da1ee chore: rename the nushell secret, and forbid reading decrypted secrets` - the no-reading
  rule.
