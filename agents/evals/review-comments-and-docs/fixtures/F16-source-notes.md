# Notes gathered for the throughput guide

- Current: the dispatcher is a polling loop, 250 ms interval, single consumer.
- Current: the queue-depth alert fires at 5,000 pending jobs.
- Applied 2026-08-14: the retry cap was lowered from 5 to 3 (`edge-admin config show retry.max`).
- Proposed 2026-09-30: move the dispatcher to an event-driven model; the reviewer asked for a load
  test first; not applied.
- Unknown: the 2026-08-02 retry-storm peak depth was never recorded. The dashboard keeps only 7
  days, so it is unrecoverable from monitoring.
- Prior history: the 2025-11-04 ledger migration moved `ledger.entries` to a partitioned table;
  online, 41 minutes.
- Side issue: the metrics-server on the same cluster crash-looped 112 times in August; unrelated to
  dispatcher throughput.
- Evidence condition: the 250 ms interval is read from the running config; the 5,000 alert threshold
  is read from the alert rule, which is not the same as the queue's actual capacity.
