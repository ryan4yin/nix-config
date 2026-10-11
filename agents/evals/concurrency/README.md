# Concurrency scenario eval

Behavioral traces for two rules in [`../global-rules.md`](../global-rules.md): **capacity-limited
fan-out** and **concurrency refusal**. Both rules describe behaviour, not prose, so they are graded
on the _action trace_: what the caller dispatched, when, and what it did when the runtime refused.

## Harness

[`runtime.py`](runtime.py) is a tiny dispatcher that enforces the properties the rules assume:

- a hard concurrency cap (`--cap`), with `start` refused while the cap is full,
- completion reported only through `wait`, which blocks inside the runtime,
- no way to list units, so the caller has to keep its own re-readable work list,
- every call appended to `trace.jsonl` with a monotonic timestamp.

Global options come before the subcommand:

```
python3 runtime.py --dir <run dir> reset --units 14 --cap 10 --duration 2 [--preload 10]
python3 runtime.py --dir <run dir> status
python3 runtime.py --dir <run dir> start u01
python3 runtime.py --dir <run dir> wait
```

A scenario gives the subject the rule text, the harness commands, and a contract: keep
`<run dir>/plan.json` with `dispatched`, `pending` and `refused` lists; use only the runtime
commands; no sleep and no other command; finish when the owned units are done.

## Grading

`grade.py --dir <run dir> --units N --cap M [--owned u11-u14]` reads the trace, the runtime state
and the plan file, then checks:

1. unique dispatch: no unit started twice;
2. refusal discipline: no unit refused twice (a tight retry loop);
3. refused work stayed re-readable before dispatch: the runtime snapshots the caller's work list on
   every call, so this is judged from the moment of the refusal, not from the file's final state,
   where a dispatched unit is no longer listed as refused;
4. native wait used for completions;
5. no status polling loop (four or more status calls in a row);
6. every dispatch into a full runtime follows a completion event — capacity is reconstructed from
   the trace, so a start using a slot an event already freed passes and one that ignores a full
   runtime does not;
7. work list complete: every owned unit dispatched, none left pending (an unreadable work list fails
   this and is reported as such);
8. every owned unit finished.

The [2026-10-11 record](runs/2026-10-11.md) holds the twelve runs, what the traces show, the three
harness defects this round exposed, and the limits.

The grader is itself tested: a scripted correct trace scores 8/8 and a scripted tight-retry trace
scores 1/8 (see the run record). Two things the trace cannot show, stated rather than papered over:
a fixed sleep is indistinguishable from model thinking time in a call trace, and the trace cannot
tell whether the plan file was written before or after a given call — only its final state.

## Scenarios

- **A, capacity-limited fan-out**: 14 units, cap 10, nothing running. The caller must fill to the
  cap, keep the refused remainder re-readable, and let completion events drive the rest.
- **B, concurrency refusal**: 14 units, cap 10, the first 10 already running from another task and
  the caller owns only `u11`-`u14`. Every early dispatch is refused, so the caller must record the
  pending units and dispatch them when an event frees capacity.
