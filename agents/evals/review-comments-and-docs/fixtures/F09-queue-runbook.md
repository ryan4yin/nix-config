# Queue drain runbook — delivery workers

On 2026-08-02 the job queue filled after a producer retry storm. The dispatcher queue grew until
pods stopped accepting work, workers logged 5xx for about 40 minutes, and on-call drained the queue
by hand.

## Current state

| Field                    | Value                    |
| ------------------------ | ------------------------ |
| Queue drain command      | `edge-admin queue drain` |
| Pending-job drain target | zero                     |
| Post-drain observation   | ten minutes              |
| Escalation               | #edge-oncall             |

## Recovery

Before restoring from a snapshot, drain the worker and wait for the pending job count to reach zero.

Recall that on 2026-08-02 the job queue filled after a producer retry storm; the dispatcher queue
grew until pods stopped accepting work, workers logged 5xx for about 40 minutes, and on-call drained
the queue by hand. That is the situation this procedure is for.

1. Run `edge-admin queue drain` and wait for pending jobs to reach zero.
2. Restore the data volume from the last snapshot.
3. Uncordon the worker and watch the queue for ten minutes.

## History

- 2026-08-02: producer retry storm filled the queue; about 40 minutes of 5xx responses; resolved by
  a manual drain and an upstream retry-cap change (issue #512).
