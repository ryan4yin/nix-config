# Storage configuration reference

## Current configuration

| Setting               | Value           |
| --------------------- | --------------- |
| Data filesystem       | ext4            |
| Data mount            | `/var/lib/edge` |
| Image backup interval | 6 hours         |

The image backup job supports ext4. Filesystem compatibility alone does not establish application
health.

## Experiment history

- 2026-09-10: changed the data volume from ext4 to XFS for a trial.
- 2026-09-11: restored ext4 because the image backup job could not process XFS. The mount and
  six-hour backup interval were unchanged.
- 2026-09-12: a backup and restore check completed successfully on ext4.
