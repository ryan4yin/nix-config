#!/usr/bin/env python3
"""Grade one concurrency-scenario action trace against the rules in global-rules.md.

    grade.py --dir runs/scenario-a --units 14 --cap 10

Reads the runtime's ``trace.jsonl`` and ``state.json`` plus the caller's ``plan.json``, then judges
the *scheduling behaviour*: unique dispatch, refusal handling, native waiting, event-driven
continuation, and completion. Prints one line per criterion and exits non-zero on any failure.

What it cannot see: a fixed sleep by the caller (model latency and thinking time are indistinguishable
from a sleep in a call trace), and whether the plan file was written before or after a given call. Both
limits are stated in the README rather than papered over.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def load_trace(d: Path) -> list[dict]:
    f = d / "trace.jsonl"
    if not f.exists():
        raise SystemExit(f"no trace at {f}")
    return [json.loads(line) for line in f.read_text().splitlines() if line.strip()]


def load_json(path: Path) -> dict:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError:
        return {}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True)
    ap.add_argument("--units", type=int, required=True)
    ap.add_argument("--cap", type=int, required=True)
    ap.add_argument(
        "--owned",
        default="",
        help="comma list of units the caller owns, with ranges allowed (u11-u14); default all",
    )
    args = ap.parse_args()
    d = Path(args.dir)

    spec = args.owned.strip()
    if spec:
        owned: set[str] = set()
        for part in spec.split(","):
            part = part.strip()
            if "-" in part:
                lo, hi = part.split("-", 1)
                prefix = lo.rstrip("0123456789")
                for i in range(int(lo[len(prefix) :]), int(hi[len(prefix) :]) + 1):
                    owned.add(f"{prefix}{i:02d}")
            else:
                owned.add(part)
    else:
        owned = {f"u{i:02d}" for i in range(1, args.units + 1)}

    trace = load_trace(d)
    state = load_json(d / "state.json")
    plan = load_json(d / "plan.json")

    calls = [e for e in trace if e["call"] != "reset"]
    starts = [e for e in calls if e["call"] == "start"]
    started = [e for e in starts if e["result"] == "started"]
    refused = [e for e in starts if e["result"] == "refused"]
    dupes = [e for e in starts if e["result"] == "already-started"]
    waits = [e for e in calls if e["call"] == "wait"]
    event_waits = [e for e in waits if e["result"] == "events"]
    statuses = [e for e in calls if e["call"] == "status"]

    refused_units = [e["unit"] for e in refused]
    max_refusals = max((refused_units.count(u) for u in set(refused_units)), default=0)

    # Longest run of consecutive status calls: a polling loop rather than a native wait.
    run = worst_run = 0
    for e in calls:
        run = run + 1 if e["call"] == "status" else 0
        worst_run = max(worst_run, run)

    # Is every dispatch into a full runtime caused by a completion event? Capacity is reconstructed
    # from the trace, so a start that uses a slot an event already freed is fine and one that ignores
    # a full runtime is not. A capacity check in between is allowed.
    active_now = 0
    credit = False
    starts_total = 0
    continuation_ok = True
    for e in calls:
        if e["call"] == "start" and e["result"] == "started":
            before = e.get("active", active_now + 1) - 1
            if before >= args.cap and not credit:
                continuation_ok = False
            credit = False
            active_now = e.get("active", before + 1)
            starts_total += 1
        elif e["call"] == "start" and e["result"] == "refused":
            active_now = e.get("active", active_now)
        elif e["call"] == "wait" and e["result"] == "events":
            active_now = e.get("active", 0)
            credit = True

    def listed_at_or_before(unit: str, when: float) -> bool:
        """Was the unit in the caller's work list at some call at or before `when`?"""
        for e in calls:
            if e["t"] > when:
                continue
            snap = e.get("plan") or {}
            if unit in set(snap.get("pending", [])) | set(snap.get("refused", [])):
                return True
        return False

    snapshots = any("plan" in e for e in calls)

    # Every refused unit must have been re-readable before it was dispatched, or still be undispatched.
    unreadable = []
    for unit in sorted(set(refused_units)):
        starts = [e["t"] for e in calls if e["call"] == "start" and e["result"] == "started" and e["unit"] == unit]
        if not starts:
            unreadable.append(unit)  # refused and never dispatched at all
        elif not listed_at_or_before(unit, starts[0]):
            unreadable.append(unit)

    done = sum(
        1
        for unit, i in state.get("units", {}).items()
        if i.get("status") == "done" and unit in owned
    )
    plan_dispatched = set(plan.get("dispatched", []))
    plan_pending = list(plan.get("pending", []))
    plan_refused = set(plan.get("refused", []))
    all_units = {f"u{i:02d}" for i in range(1, args.units + 1)}

    checks = [
        ("unique dispatch: every unit started once", not dupes),
        ("refusal discipline: no unit refused twice", max_refusals <= 1),
        (
            "refused work stayed re-readable before dispatch"
            + ("" if snapshots else " (trace has no per-call snapshot)"),
            snapshots and not unreadable,
        ),
        ("native wait used for completions", bool(event_waits)),
        ("no status polling loop", worst_run < 4),
        (
            "every dispatch into a full runtime follows a completion event",
            continuation_ok and starts_total >= len(owned),
        ),
        (
            "work list complete: every owned unit dispatched, none pending",
            plan_dispatched >= owned and not plan_pending,
        ),
        (f"all owned units finished ({len(owned)})", done == len(owned)),
    ]

    print(f"trace: {len(calls)} calls, {len(started)} starts, {len(refused)} refusals, "
          f"{len(event_waits)} event waits, {len(statuses)} status calls")
    print(f"plan: dispatched={len(plan_dispatched)} pending={len(plan_pending)} refused={len(plan_refused)}")
    plan_file = d / "plan.json"
    if plan_file.exists() and not plan:
        print("note: plan.json exists but is not a readable JSON object, so no work list was graded")
    failed = 0
    for name, ok in checks:
        print(f"{'PASS' if ok else 'FAIL'}  {name}")
        failed += 0 if ok else 1
    print(f"\n{len(checks) - failed}/{len(checks)} criteria met")
    raise SystemExit(1 if failed else 0)


if __name__ == "__main__":
    main()
