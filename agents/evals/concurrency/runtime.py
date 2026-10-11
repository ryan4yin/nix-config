"""A tiny runtime with a hard concurrency cap and event-reported completion.

It exists to observe an agent's *scheduling behaviour*: the trace of every call it makes. The
runtime accepts at most ``--cap`` concurrent units, refuses more until one finishes, and reports
completion only through ``wait``, which blocks in the runtime rather than in the caller. There is
deliberately no polling primitive and no way to list units, so the caller has to keep its own
re-readable work list.

Global options come before the subcommand:

    runtime.py --dir D reset --units N --cap M --duration S [--preload P]
    runtime.py --dir D start UNIT
    runtime.py --dir D wait [--timeout S]
    runtime.py --dir D status

State lives in ``<dir>/state.json``; every call is appended to ``<dir>/trace.jsonl``.
"""

from __future__ import annotations

import argparse
import fcntl
import json
import time
from contextlib import contextmanager
from pathlib import Path

DEFAULT_DIR = Path(__file__).resolve().parent


@contextmanager
def state_lock(d: Path):
    """Serialize state and trace updates; release the lock between wait iterations."""
    with (d / "state.lock").open("a") as lock:
        deadline = time.monotonic() + 5
        while True:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except BlockingIOError:
                if time.monotonic() >= deadline:
                    raise SystemExit("state lock timed out") from None
                time.sleep(0.01)
        try:
            yield
        finally:
            fcntl.flock(lock, fcntl.LOCK_UN)


def paths(d: Path) -> tuple[Path, Path]:
    return d / "state.json", d / "trace.jsonl"


def load_state(d: Path) -> dict:
    state, _ = paths(d)
    if not state.exists():
        raise SystemExit("no state; run `runtime.py reset` first")
    return json.loads(state.read_text())


def save_state(d: Path, state: dict) -> None:
    state_file, _ = paths(d)
    state_file.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n")


def trace(d: Path, entry: dict) -> None:
    _, trace_file = paths(d)
    # Snapshot the caller's work list, if it keeps one, so the "refused work stays re-readable" rule
    # can be graded from the trace instead of from the file's final state.
    plan_file = d / "plan.json"
    if plan_file.exists():
        try:
            raw = json.loads(plan_file.read_text())
            entry["plan"] = {
                k: sorted(raw.get(k, [])) for k in ("dispatched", "pending", "refused")
            }
        except (json.JSONDecodeError, AttributeError):
            entry["plan"] = {"unparsable": True}
    entry = {
        "t": round(time.monotonic(), 3),
        "wall": time.strftime("%H:%M:%S"),
        **entry,
    }
    with trace_file.open("a") as fh:
        fh.write(json.dumps(entry, sort_keys=True) + "\n")


def finish_ready(state: dict) -> list[dict]:
    """Mark every running unit whose duration has elapsed as done, and return those events."""
    now = time.monotonic()
    events = []
    for unit, info in sorted(state["units"].items()):
        if info["status"] == "running" and now >= info["started"] + state["duration"]:
            info["status"] = "done"
            events.append({"unit": unit, "status": "done"})
    return events


def active(state: dict) -> int:
    return sum(1 for i in state["units"].values() if i["status"] == "running")


def cmd_reset(args) -> None:
    d = Path(args.dir)
    units = {f"u{i:02d}": {"status": "pending"} for i in range(1, args.units + 1)}
    state = {"units": units, "cap": args.cap, "duration": args.duration}
    _, trace_file = paths(d)
    trace_file.write_text("")
    now = time.monotonic()
    preloaded = 0
    for unit in sorted(units):
        if preloaded >= args.preload:
            break
        if preloaded >= args.cap:
            break
        units[unit] = {
            "status": "running",
            "started": now - args.duration + args.preload_remaining,
        }
        preloaded += 1
    save_state(d, state)
    trace(d, {"call": "reset", "units": args.units, "cap": args.cap, "preload": preloaded})
    print(
        json.dumps(
            {
                "status": "ready",
                "units": args.units,
                "cap": args.cap,
                "preload": preloaded,
            }
        )
    )


def cmd_start(args) -> None:
    d = Path(args.dir)
    state = load_state(d)
    unit = args.unit
    if unit not in state["units"]:
        trace(d, {"call": "start", "unit": unit, "result": "unknown-unit"})
        print(json.dumps({"status": "error", "reason": "unknown unit"}))
        return
    if state["units"][unit]["status"] != "pending":
        trace(d, {"call": "start", "unit": unit, "result": "already-started"})
        print(json.dumps({"status": "error", "reason": "unit not pending"}))
        return
    if active(state) >= state["cap"]:
        trace(
            d,
            {
                "call": "start",
                "unit": unit,
                "result": "refused",
                "active": active(state),
            },
        )
        print(json.dumps({"status": "refused", "active": active(state), "cap": state["cap"]}))
        return
    state["units"][unit] = {"status": "running", "started": time.monotonic()}
    save_state(d, state)
    trace(d, {"call": "start", "unit": unit, "result": "started", "active": active(state)})
    print(json.dumps({"status": "started", "unit": unit, "active": active(state)}))


def cmd_wait(args) -> None:
    d = Path(args.dir)
    deadline = time.monotonic() + args.timeout
    while True:
        with state_lock(d):
            state = load_state(d)
            events = finish_ready(state)
            if events:
                save_state(d, state)
                trace(
                    d,
                    {
                        "call": "wait",
                        "result": "events",
                        "events": [e["unit"] for e in events],
                    },
                )
                print(json.dumps({"events": events, "active": active(state)}))
                return
            if active(state) == 0:
                trace(d, {"call": "wait", "result": "idle"})
                print(json.dumps({"events": [], "active": 0, "note": "nothing running"}))
                return
            if time.monotonic() >= deadline:
                trace(d, {"call": "wait", "result": "timeout"})
                print(json.dumps({"events": [], "active": active(state), "timeout": True}))
                return
        time.sleep(0.025)


def cmd_status(args) -> None:
    d = Path(args.dir)
    state = load_state(d)
    counts = {"pending": 0, "running": 0, "done": 0}
    for info in state["units"].values():
        counts[info["status"]] += 1
    trace(d, {"call": "status", **counts})
    print(json.dumps({"cap": state["cap"], **counts}))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dir", default=str(DEFAULT_DIR))
    sub = parser.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("reset")
    p.add_argument("--units", type=int, required=True)
    p.add_argument("--cap", type=int, required=True)
    p.add_argument("--duration", type=float, default=2.0)
    p.add_argument("--preload", type=int, default=0)
    p.add_argument(
        "--preload-remaining",
        type=float,
        default=25.0,
        help="seconds until preloaded units finish",
    )
    p.set_defaults(func=cmd_reset)

    p = sub.add_parser("start")
    p.add_argument("unit")
    p.set_defaults(func=cmd_start)

    p = sub.add_parser("wait")
    p.add_argument("--timeout", type=float, default=20.0)
    p.set_defaults(func=cmd_wait)

    sub.add_parser("status").set_defaults(func=cmd_status)

    args = parser.parse_args()
    if args.cmd == "reset":
        Path(args.dir).mkdir(parents=True, exist_ok=True)
    if args.cmd == "wait":
        args.func(args)
    else:
        with state_lock(Path(args.dir)):
            args.func(args)


if __name__ == "__main__":
    main()
