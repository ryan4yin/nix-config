# Service incidents and migrations

## 2025-11-04 — ledger schema v3

Moved `ledger.entries` to a partitioned table. The migration ran online and took 41 minutes; the
backfill of 12.4M rows completed 2025-11-05 02:10 UTC. No application downtime.

## 2026-02-18 — queue outage (incident 2026-02-18)

The job queue lost 3 hours of deliveries between 09:12 and 12:07 UTC after a disk filled. Root
cause: log rotation was configured on the node but not on the new volume. Recovery restored 2,180 of
the 2,436 queued jobs; the rest were replayed from producers.

## 2026-05-30 — cache namespace migration

Renamed the `cache:v1` namespace to `cache:v2` and expired the old keys. Reads fell back to the
database for about six hours.

- TODO(2026-06-02): verify the exact end time of the 2026-05-30 fallback from the proxy logs; the
  six-hour figure is rounded and has not been confirmed.
- I am still rewriting this in my scratch buffer; half of the 2026-05-30 entry is not written up.
- TODO: at some point move these entries into the team wiki.
