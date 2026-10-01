---
name: Nix Config Secrets
description:
  Use when adding, changing, renaming, or removing an agenix secret, wiring one into a host, or
  fixing a decryption or activation failure in this repo.
---

# Working with secrets

Secrets are age-encrypted blobs that live in a separate private repository (`nix-secrets`, pulled in
as the `mysecrets` flake input) and are declared here in `secrets/nixos.nix` and
`secrets/darwin.nix`. No secret value is ever stored in this repository.

Read [secrets/README.md](../../../secrets/README.md) for the private-repository workflow. This skill
covers the repo-side change and the traps.

## Core rules

1. **Never read a decrypted secret.** Reference its path; do not `cat`, copy, or print it. The repo
   says this explicitly for `nushell-secrets.nu`, and the global rules say it for any secret. If you
   need to prove a change worked, inspect metadata (mode, owner, timestamps), not content.
2. **Two repositories, two commits.** The recipient list and the encrypted blob change in
   `nix-secrets`; the declaration and the consumer change here. A secret added on only one side
   decrypts nowhere or references nothing.
3. **Every secret stays decryptable by the desktops.** A recipient set is
   `desktop_keys ++ <the hosts that need it>`, and `recovery_key` is a member of `desktop_keys`.
   Narrowing a set to the servers alone locks out the desktops and the only offline recovery key
   together. The exception is `restic-password-desktop.age`: `desktop_keys` alone, so the backup
   servers cannot read desktop data.
4. **Least privilege on the decrypted file.** Pick the weakest mode that still works for the
   consumer, and set the owner at the same time as the mode.
5. **A stale declaration breaks activation.** Removing or renaming a secret means changing every
   reference in the same change, including `secrets.nix` in the private repository.

## 1. Where the pieces live

| Piece                                                 | Location                                                                                                                   |
| ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Recipient list, encrypted blobs, `agenix` CLI         | the private `nix-secrets` repository (`mysecrets` flake input)                                                             |
| NixOS declaration: file, mode/owner, `/etc` placement | `secrets/nixos.nix`                                                                                                        |
| macOS declaration                                     | `secrets/darwin.nix`                                                                                                       |
| Which hosts get which group                           | `modules.secrets.<group>.enable` in the host's `outputs/<system>/src/*.nix`                                                |
| Consumers                                             | `home/**` and `modules/**` reading `/etc/agenix/<name>`                                                                    |
| Decryption key                                        | `age.identityPaths`: `/etc/ssh/ssh_host_ed25519_key`, or `/persistent/etc/ssh/ssh_host_ed25519_key` on a preservation host |

Non-secret material also comes from `mysecrets` (for example `public/romantic.pub`); only the
encrypted files are sensitive.

## 2. Add or change a secret

1. In the private repository, add the file to `secrets.nix` with the recipient set from core rule 3.
2. Create or edit the blob on a desktop, which holds the trusted keys:

   ```bash
   sudo agenix -e ./xxx.age -i /etc/ssh/ssh_host_ed25519_key
   ```

3. Here, declare it in `secrets/nixos.nix` or `secrets/darwin.nix`, under the right
   `modules.secrets.<group>` gate, and give it a mode/owner pair.
4. Wire the consumer to the runtime path (`/etc/agenix/<name>`, or
   `config.age.secrets."<name>".path` for a systemd unit).
5. Deploy, then verify as in step 4 below.

## 3. Modes and ownership

`secrets/nixos.nix` defines three presets; reuse them instead of new literals:

| Preset          | Mode / owner    | Use for                                          |
| --------------- | --------------- | ------------------------------------------------ |
| `noaccess`      | `0000` root     | a file nothing should read directly              |
| `high_security` | `0500` root     | root-only consumers (services, activation)       |
| `user_readable` | `0500` `<user>` | anything a Home Manager module or the user reads |

The trap: `environment.etc."agenix/<name>"` with a `mode` **copies** the file instead of symlinking
the runtime secret, and the copy defaults to root-owned and world-readable unless you also set
`user`. That is how a secret ends up readable by every local account. Set both, or neither:

```nix
"agenix/nushell-secrets.nu" = {
  source = config.age.secrets."nushell-secrets.nu".path;
  mode = "0400";
  user = myvars.username; # required whenever mode is set
};
```

nix-darwin does not support `mode`/`user` on `environment.etc` at all; `secrets/darwin.nix` chowns
`/etc/agenix/*` in a post-activation script instead.

A file whose _decrypted_ content is still an age-encrypted blob keeps `.age` in its name
(`ryan4yin-gpg-subkeys.priv.age`); a plaintext secret drops it (`xxx.age` encrypts to `xxx`).

## 4. Verify without reading

```bash
stat -c '%a %U:%G' /etc/agenix/<name>   # mode and owner, not content
ls -l /etc/agenix/
journalctl | grep -5 agenix                                        # NixOS
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stderr.log     # macOS
```

A successful activation is silent, so absence of an error is the pass. Confirm that the _access_
changed: if the point of the change was to stop a world-readable copy, check that the copy is gone
and the mode is what you set, rather than assuming activation did it. Never verify by decrypting and
printing.

## 5. Remove or rename a secret

- Delete the `age.secrets` entry, its `environment.etc` placement, and the consumer together.
- Remove it from `secrets.nix` and the blob in the private repository.
- Renaming is a change to the key _and_ every consumer; the `.age` filename is independent, so do
  not rename one without the other.

## 6. Failure modes

- **Decryption fails at activation on one host** — its host key is not in the recipient set. Add
  `cat /etc/ssh/ssh_host_ed25519_key.pub` to the private `secrets.nix`, rekey with
  `sudo agenix -r -i /etc/ssh/ssh_host_ed25519_key` on a desktop, push, and redeploy.
- **`permission denied` for a user service** — the consumer reads a `high_security` secret. Fix the
  owner for that secret; do not widen the mode to `0644`.
- **Preservation hosts cannot decrypt at boot** — `age.identityPaths` must point at
  `/persistent/etc/ssh/ssh_host_ed25519_key`, not the preservation-mounted `/etc/...`.
- **Base configuration must not depend on a secret** — if a shared `home/base` module needs it, the
  dependency belongs in the host module or a guarded `mkIf`.
- **The first macOS activation fails** — it runs before `activate-agenix`; rerun it and the chown
  step settles ownership.

## Lessons from past changes

These all happened in this repository; they are the reason for the steps above.

- `4909f635 security: scope privileges and stop a world-readable secret copy (#335)` — the
  `environment.etc` copy above: setting `mode` without `user` produced a world-readable root-owned
  copy of a user-readable secret.
- `c8e76cef fix(darwin): agenix - remove non-exist secret` — a declaration left behind after the
  blob was deleted broke activation.
- `260da1ee chore: rename the nushell secret, and forbid reading decrypted secrets` and
  `ef00eb31 docs: warn that user-readable decrypted secrets must not be read (#303)` — the
  no-reading rule, and why a rename has to move every consumer.
- `8b1fa3ac chore(secrets): drop the unreferenced dae-subscription secret` — unreferenced secrets
  are worth deleting; they are still exposure.
- `a43aa02a`, `89e57b5b`, `1cbb52ad docs(secrets): ...` — the recipient invariant, written down
  after it was nearly broken by narrowing a set to the servers.
- `4211d18a` — a shared `home/base` module must not depend on an agenix secret at build time; the
  dependency belongs to the host module (the commit subject has a typo, hence the paraphrase).
