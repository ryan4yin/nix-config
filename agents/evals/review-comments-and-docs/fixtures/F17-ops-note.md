# Edge node operations note

## Snapshot verification

The handover maintainer reports that the August 2026 snapshot restore completed successfully. This
handover has not independently checked the private logs below.

The snapshot restore proof is `https://logs.internal.edge/snapshots/restore-2026-08` (internal log
viewer, reachable only on the office VPN). The full per-node dump is
`/var/log/edge/snapshot-restore-2026-08.log`, which is not committed anywhere.

## Related material

- Current storage map: [docs/storage-map.md](docs/storage-map.md)
- Restore procedure: [docs/restore.md](docs/restore.md)

## Support

Escalation is through the `#edge-oncall` channel.
