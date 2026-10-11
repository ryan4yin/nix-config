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

`status` only observes saved counts; elapsed time alone does not release a slot. A per-directory
file lock serializes state and trace updates across processes. `wait` releases that lock between
checks so other commands can proceed; lock acquisition has a five-second timeout.

Global options come before the subcommand:

```
python3 runtime.py --dir <run dir> reset --units 14 --cap 10 --duration 2 [--preload 10 --preload-remaining 60]
python3 runtime.py --dir <run dir> status
python3 runtime.py --dir <run dir> start u01
python3 runtime.py --dir <run dir> wait
```

A scenario gives the subject the rule text, the harness commands, and a contract: keep
`<run dir>/plan.json` with `dispatched`, `pending` and `refused` lists; use only the runtime
commands; no sleep and no other command; finish when the owned units are done.

## Grading

`python3 grade.py --dir <run dir> --units N --cap M [--owned u11-u14]` reads the trace, the runtime
state and the plan file. It rejects a scenario with no real capacity refusal or a mismatched reset,
then checks:

1. unique dispatch: no unit started twice;
2. refusal discipline: no unit refused twice (a tight retry loop);
3. refused work stayed re-readable before dispatch: the runtime snapshots the caller's work list on
   every call, so this is judged from the moment of the refusal, not from the file's final state,
   where a dispatched unit is no longer listed as refused;
4. native wait events observed for every owned completion;
5. no status polling loop (four or more status calls in a row);
6. every dispatch into a full runtime follows a completion event — capacity is reconstructed from
   the trace, so a start using a slot an event already freed passes and one that ignores a full
   runtime does not;
7. work list complete: every owned unit dispatched, none left pending (an unreadable work list fails
   this and is reported as such);
8. every owned unit finished.

The [2026-10-11 record](runs/2026-10-11.md) keeps the twelve model runs and historical scorer
results. The corrected scorer was checked against those existing local traces without rerunning the
actors: eleven still score 8/8 and B/luna-2 scores 7/8.

Run the focused regressions from the repository root:

```
python3 -B -m unittest discover -s agents/evals/concurrency -v
```

They cover concurrent starts, status/event separation, a valid event-driven trace, rejection of the
old status bypass, preloaded capacity and an unexercised scenario. No model or Nix build is
involved.

A call trace cannot distinguish a fixed sleep from thinking time, or prove the caller re-read its
plan. Snapshots only show what the plan contained when each command ran; they do not record file
reads or every write.

## Scenarios

- **A, capacity-limited fan-out**: 14 units, cap 10, nothing running. The caller must fill to the
  cap, keep the refused remainder re-readable, and let completion events drive the rest.
- **B, concurrency refusal**: 14 units, cap 10, the first 10 already running from another task and
  the caller owns only `u11`-`u14`. Every early dispatch is refused, so the caller must record the
  pending units and dispatch them when an event frees capacity.
