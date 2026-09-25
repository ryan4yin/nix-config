# Immich (photo platform)

Design for the homelab photo platform on youko. Implementation lives in `./default.nix`; this
document is the agreed design and the rationale.

## Goal

- Browse and search the existing 36G phone gallery (`/data/fileshare/mydata/DCIM`) **in place**,
  with ML (faces, objects) and duplicate detection.
- Keep the footprint reasonable next to the k3s microVMs on the same 22G host.

## Non-goals (for now)

- Scheduled phone background backup (the mobile app is used for manual uploads).
- Multi-user / family accounts and public share links.
- Off-host/off-site copy — deferred to the planned cloud backup (see Backup).

## Decisions

- **App**: Immich via the nixpkgs `services.immich` module — a native systemd service, **not**
  containers.
- **Database**: reuse the host PostgreSQL 16 (`services.postgresql`) instead of a bundled DB
  container.
- **Cache**: a single shared **Valkey** instance (`services.redis.package = pkgs.valkey`), reused by
  Immich and future services over loopback TCP — not a private per-service Redis, and not Dragonfly
  (its Lua handling breaks Immich's BullMQ job queue; see Risks).
- **Existing photos**: exposed as a read-only Immich **External Library**, not imported/copied (no
  36G duplication).
- **ML**: enable it, running on **CPU** initially.

## Architecture

- `services.immich` (server) on youko; `host = "127.0.0.1"`, `port = 2283`.
- `services.immich.database.enable = true` and `createDB = true`: the module adds `pgvector` +
  `vectorchord` to `services.postgresql`, sets `shared_preload_libraries = [ "vchord.so" ]`, and
  creates the `immich` database/user. Confirmed present in this flake's nixpkgs: PG 16.15,
  `pgvector` 0.8.6, `vectorchord` 1.1.1, `immich` 3.2.2.
- `services.immich.redis.enable = false` with `host = "127.0.0.1"` and `port = 6379`: Immich uses
  the shared Valkey instance (`../valkey.nix`) over loopback TCP; the module then passes
  `REDIS_HOSTNAME`/`REDIS_PORT`.
- `services.immich.machine-learning.enable = true` (CPU; `accelerationDevices` left unset — AMD iGPU
  ML is unreliable, revisit `/dev/dri/renderD128` later).
- Caddy vhost `immich.writefor.fun` -> `http://127.0.0.1:2283`. Unlike the other vhosts (private
  `ecc-ca`), this one is reached by the Immich mobile app, so it gets a publicly-trusted Let's
  Encrypt cert via `security.acme` (lego + Cloudflare DNS-01); see `../caddy.nix`.
- A `homepage` entry on the dashboard.

## Storage

- `mediaLocation = "/data/apps/immich"` (the encrypted HDD; ~3.5T free), created by tmpfiles as
  `d /data/apps/immich 0750 immich immich`. This holds the managed library and generated
  thumbnails/transcodes.
- The Immich database lives in the Postgres data directory (`/var/lib/postgresql/16`), i.e. under
  `@persistent`.

## Photo sources and permissions

- The DCIM tree is `0700`, owned by `sftpgo` (`sftpgo:postgres-exporter`). Grant the `immich` user
  read access with a recursive **and default** ACL (`u:immich:rX` + `d:u:immich:rX`) so existing and
  future files stay readable, without loosening the tree for everyone.
- In the Immich admin UI, add an External Library pointing at the DCIM path and run a scan. Files
  stay read-only to Immich; albums/faces metadata is stored in the database.

## Backup and disaster recovery

- **Database**: already covered by the existing youko restic backup, which snapshots
  `/btr_pool/@persistent` (Postgres data lives there).
- **Media and existing photos**: both live on the HDD already. A local HDD->HDD backup adds no
  protection, so none is added here. This is deferred to the planned cloud copy, which will cover
  the photo library.
- **Note for the cloud-copy work**: a raw btrfs snapshot of a running Postgres is only
  crash-consistent; prefer a `pg_dump` into the cloud set for a clean restore. That set should
  include `mediaLocation` and the external-library source.
- **One-time disruption**: adding the extensions and `shared_preload_libraries` restarts PostgreSQL
  (affects the `playground` DB only).

## Monitoring

- Deferred: Immich can expose `IMMICH_API_METRICS_PORT` / `IMMICH_MICROSERVICES_METRICS_PORT`, but
  youko has no host firewall, so enabling them now would publish those ports on the LAN. Revisit
  together with a firewall rule.

## Risks

- Immich's job queue (BullMQ) needs a Redis that tolerates Lua scripts accessing dynamically-built
  keys; **Dragonfly rejected these** (`script tried accessing undeclared key`) and every upload
  returned 500. We therefore run **Valkey** (`services.redis`), Redis-compatible and the supported
  backend.

## Resource budget

- Immich server + ML worker + Redis: roughly 2-4G RAM, alongside the k3s microVMs; youko has ~13G
  available.

## Rollout

1. `../valkey.nix`: the shared Valkey instance.
2. `./default.nix`: the `services.immich` configuration (server, database, machine-learning,
   tmpfiles).
3. `../caddy.nix`: the `immich.writefor.fun` vhost.
4. `../oci-containers/homepage/config/services.yaml`: dashboard entry.
5. Deploy: `colmena apply dry-activate` then `switch --on '@youko'`.
6. Register the first user (becomes admin), disable open signup, add the external library, trigger a
   scan.

## Validation

- `just fmt`; `just test` -> `true`; `nix build` the youko toplevel.
- Postgres: `\dx` lists `vectorchord`/`pgvector`; `SHOW shared_preload_libraries` includes
  `vchord.so`; the `immich` DB exists.
- Units: `immich-server`, `immich-machine-learning`, `redis-shared`, `postgresql` are active.
- `curl 127.0.0.1:2283` and `https://immich.writefor.fun` respond; login works; the external library
  scan indexes the DCIM photos and ML search returns results.

## Future

- iGPU ML (`/dev/dri/renderD128`) if it proves reliable.
- `immich-public-proxy` / `immich-kiosk` / `immichframe` for sharing and dashboards.
- Mobile apps and phone auto-backup.
- `pg_dump` of the Immich DB into the cloud backup set.
