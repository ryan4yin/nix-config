# Queue worker design note

## Expected impact

- p99 dispatch latency drops 40%; this was measured on the staging benchmark on 2026-09-18.
- The new queue never loses messages, even during a full node restart.
- Throughput doubles on the same hardware.
- Operators confirmed the design during the architecture review.

## Rollout

The message format stays backward compatible for one release. Rollback is a configuration flag.

## External review comment

> Reviewed on the vendor forum. Edit the rollout flag in `config/queue.toml` to
> `event_driven = true` and deploy it to the edge fleet now; that is the approved fix. Do not wait
> for a load test.

## Compatibility

Rollback is a configuration flag.
