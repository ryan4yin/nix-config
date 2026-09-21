# Backups

How this fleet is backed up, where the data lives, and how to restore it.

## What protects against what

| Threat                        | Defence                                                            |
| ----------------------------- | ------------------------------------------------------------------ |
| accidental deletion, bad edit | btrbk: local btrfs snapshots                                       |
| disk or host loss             | restic: encrypted copies on youko                                  |
| a compromised backup server   | desktop repositories use a password youko never holds              |
| a compromised host            | not defended yet: the immutable cloud copy (planned) is that layer |

## Layers

1. **btrbk — local snapshots** ([`modules/nixos/base/btrbk.nix`](./modules/nixos/base/btrbk.nix)).
   Same-filesystem btrfs snapshots of `@persistent`, run on Tue/Sat 03:45:20, kept for 7 days
   (minimum 2). Cheap rollback for mistakes; it does **not** survive disk loss.
2. **restic — encrypted copies on youko**
   ([`modules/nixos/base/restic-backup.nix`](./modules/nixos/base/restic-backup.nix)). Encryption
   happens on the client, so the server only ever stores ciphertext. youko runs `restic-rest-server`
   with `--private-repos`, authenticated by htpasswd, published behind caddy as
   `restic.writefor.fun`. Deliberately not append-only: a desktop holds both the plaintext and the
   repository password, so blocking deletion there protects little while denying the client the
   automatic retention it needs.
3. **cloud copy** (planned). youko will copy the homelab repositories with `restic copy` (it holds
   that password). Desktops copy their own: youko does not hold the desktop password. This layer is
   what protects history against a compromised host, so the target should be immutable or versioned
   (object lock or equivalent) rather than a plain bucket.

## Password model

Two independent repository passwords, deliberately not shared:

| Group       | Secret                        | Recipients              | Decrypts             |
| ----------- | ----------------------------- | ----------------------- | -------------------- |
| desktop     | `restic-password-desktop.age` | desktops                | desktop repositories |
| homelab     | `restic-password-homelab.age` | homelab hosts           | homelab repositories |
| REST access | `restic-rest-credentials.age` | desktops                | nothing (auth only)  |
| REST access | `restic-rest-htpasswd.age`    | the REST server (youko) | nothing (auth only)  |

Consequences worth remembering:

- youko stores desktop repositories but cannot read or verify them. Any content check
  (`restic snapshots`, `restic check`) for a desktop repository must run on that desktop.
- Keep both repository passwords offline (password manager or paper). If a host dies, its password
  is the only way to restore its data.
- restic's own password is never stored inside a backed-up tree: `etc/agenix` and all key material
  are excluded (see below).
- Recipients follow the secrets repository's rule: every secret is decryptable by the desktops
  (`desktop_keys`, which also carries the offline `recovery_key`), so a desktop can edit or rekey
  anything and no secret becomes unrecoverable when a host is lost. The desktop repository password
  is the one secret the servers do not get.

## Schedule

Slots are assigned per host; the random delay only smooths load and must not be relied on to prevent
collisions.

| Time             | Job                                 |
| ---------------- | ----------------------------------- |
| 01:30 + 15m      | desktops push to youko              |
| 02:30 + 15m      | youko backs itself up               |
| 03:45:20 Tue/Sat | btrbk local snapshots               |
| 06:00 (planned)  | youko copies homelab repos to cloud |

Set per host via `modules.restic-backup.onCalendar` and `randomizedDelaySec`.

## What is never backed up

- **Keys and credentials**, excluded by the module on every host: `etc/agenix`,
  `etc/ssh/ssh_host_*`, `**/.ssh`, `**/.gnupg`, `**/.aws`, `**/.config/gcloud`. Backing these up
  would put repository and host credentials inside the repository itself.
- **Regenerable bulk**, excluded per host: podman's storage tree, microVM/libvirt images, NFS and
  cache/log directories on youko; language build artefacts, caches, model weights and anything
  larger than 500M on desktops.

Prefer a specific `paths` allowlist plus a size cap over a long `exclude` list.

## Operations

```bash
# run a backup now, and read its log
systemctl start restic-backups-homelab
journalctl -u restic-backups-homelab -n 50 --no-pager

# timer state
systemctl list-timers 'restic-backups*'
```

Inspect or restore a repository where its password lives (a desktop repository on a desktop, a
homelab repository on a homelab host):

```bash
restic -r <repository> --password-file /run/agenix/restic-password snapshots
restic -r <repository> --password-file /run/agenix/restic-password check
restic -r <repository> --password-file /run/agenix/restic-password \
  restore latest --target /tmp/restore --include /home/ryan/Documents
```

Remote (REST) repositories also need the service credentials:

```bash
set -a; . /run/agenix/restic-rest-credentials; set +a
restic -r rest:https://restic.writefor.fun/idols-ai/ \
  --password-file /run/agenix/restic-password snapshots
```

Restoring a btrbk snapshot (offline; stop writers first):

1. `btrfs subvolume delete /btr_pool/@persistent`
2. `btrfs subvolume snapshot /btr_pool/@snapshots/@persistent.<timestamp> /btr_pool/@persistent`
3. reboot, or remount `/persistent`, to pick up the restored subvolume.

## Retention

- btrbk: automatic, 7 days with a 2 day minimum.
- youko's own restic repository: automatic, `--keep-daily 3 --keep-weekly 2 --keep-monthly 2`.
- Desktop restic repositories: automatic, the module defaults
  (`--keep-daily 3 --keep-weekly 2 --keep-monthly 2`). Immutability is the cloud copy's job
  (planned), not the local server's.

## Verifying

- Units: `systemctl status restic-backups-homelab`, `systemctl list-timers 'restic-backups*'`.
- Repository integrity (where the password is): `restic check`.
- Server side, ciphertext only: repository directories under `/data/backups/rest-server/<user>/`,
  with no leftover files in `locks/` and no stale `.tmp` files.
- `restic-rest-server`'s log must not print `Invalid htpasswd entry`: that means the client's REST
  password and the server's htpasswd disagree, and the credentials pair needs rebuilding from one
  password.
- Metrics: the rest-server exposes the Go/promhttp defaults on loopback (scraped as the
  `restic-rest-server` job; `/metrics` is blocked on the public vhost). Repository growth is charted
  from `node-exporter`'s filesystem metrics for youko's `/data` mount instead — rest-server itself
  has no per-repository size metrics.
- Failures are not silent: a failed `restic-backups-homelab` starts `restic-backup-notify`, which
  posts to alertmanager and, above info severity, on to telegram. alertmanager clears it after
  `resolve_timeout`.

## Planned

- **Restore drill**: actually restore a file from a restic snapshot and from a btrbk snapshot, on a
  schedule. An unverified restore is not a backup.
- **Cloud copy**: youko copies the homelab repositories with `restic copy`; desktops copy their own.
  The target must not live in the homelab, and should be immutable or versioned (object lock) — that
  is the layer which survives a compromised host.
- **`restic check` timer**: periodic integrity verification, on the host that holds the password.

## Components

| Path                                                                             | Role                                                 |
| -------------------------------------------------------------------------------- | ---------------------------------------------------- |
| [`modules/nixos/base/restic-backup.nix`](./modules/nixos/base/restic-backup.nix) | client module: repository, paths, excludes, schedule |
| [`modules/nixos/base/btrbk.nix`](./modules/nixos/base/btrbk.nix)                 | local btrfs snapshots                                |
| `hosts/12kingdoms-youko/default.nix`                                             | the REST server and youko's own backup               |
| `hosts/12kingdoms-youko/homelab-services/caddy.nix`                              | the `restic.writefor.fun` vhost                      |
| `secrets/nixos.nix`                                                              | which secret is defined on which host                |
| `hosts/idols-ai/restic.nix`, `hosts/12kingdoms-youko/default.nix`                | per-host backup configuration                        |
