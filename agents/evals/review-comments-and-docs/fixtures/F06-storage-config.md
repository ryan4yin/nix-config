# Edge storage operating configuration

## Current configuration

The data volume has been restored to **ext4**. After that reversal, the worker is back on the
previous setup, so use it for normal operation.

| Field           | Current value   |
| --------------- | --------------- |
| Filesystem      | ext4            |
| Mount           | `/var/lib/edge` |
| Backup interval | 6 hours         |

## Recovery procedure

Before restoring a snapshot, drain the worker and wait until pending jobs reach zero. Restore the
data volume, then uncordon the worker and observe the queue for ten minutes.

## Compatibility

The image backup job supports ext4 data volumes. Filesystem choice alone does not establish service
health; monitor application errors during normal operation.

## Experiment history

- 2026-09-10: changed the data volume from ext4 to XFS for a trial.
- 2026-09-11: the image backup job could not process the XFS volume. The filesystem was reverted
  from XFS to ext4; the mount and six-hour backup schedule were unchanged.
- 2026-09-12: a backup and restore check completed successfully on ext4.
