"""Focused runtime and grader regressions: python3 -B -m unittest discover -s agents/evals/concurrency."""

import fcntl
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent


class ConcurrencyTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.d = Path(self.tmp.name)

    def runtime(self, *args):
        result = subprocess.run(
            [sys.executable, str(ROOT / "runtime.py"), "--dir", str(self.d), *args],
            capture_output=True,
            text=True,
            check=True,
            timeout=8,
        )
        return json.loads(result.stdout)

    def plan(self, pending, dispatched):
        (self.d / "plan.json").write_text(
            json.dumps(
                {
                    "pending": pending,
                    "dispatched": dispatched,
                    "refused": [],
                }
            )
        )

    def grade(self, units, cap, *args):
        return subprocess.run(
            [
                sys.executable,
                str(ROOT / "grade.py"),
                "--dir",
                str(self.d),
                "--units",
                str(units),
                "--cap",
                str(cap),
                *args,
            ],
            capture_output=True,
            text=True,
            check=False,
            timeout=8,
        )

    def test_status_cannot_release_capacity(self):
        self.runtime("reset", "--units", "3", "--cap", "2", "--duration", "0")
        self.plan(["u01", "u02", "u03"], [])
        self.runtime("start", "u01")
        self.runtime("start", "u02")
        self.assertEqual(self.runtime("start", "u03")["status"], "refused")
        self.assertEqual(self.runtime("status")["running"], 2)
        self.assertEqual(self.runtime("start", "u03")["status"], "refused")
        events = self.runtime("wait", "--timeout", "1")["events"]
        self.assertEqual({e["unit"] for e in events}, {"u01", "u02"})
        self.assertEqual(self.runtime("start", "u03")["status"], "started")

    def test_parallel_starts_share_lock_and_preserve_state(self):
        self.runtime("reset", "--units", "2", "--cap", "1", "--duration", "30")
        processes = []
        try:
            with (self.d / "state.lock").open("a") as lock:
                fcntl.flock(lock, fcntl.LOCK_EX)
                for unit in ("u01", "u02"):
                    processes.append(
                        subprocess.Popen(
                            [
                                sys.executable,
                                str(ROOT / "runtime.py"),
                                "--dir",
                                str(self.d),
                                "start",
                                unit,
                            ],
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            text=True,
                        )
                    )
                for process in processes:
                    with self.assertRaises(subprocess.TimeoutExpired):
                        process.communicate(timeout=0.1)
            results = []
            for process in processes:
                stdout, stderr = process.communicate(timeout=8)
                self.assertEqual(process.returncode, 0, stderr)
                results.append(json.loads(stdout)["status"])
            self.assertCountEqual(results, ["started", "refused"])
            state = json.loads((self.d / "state.json").read_text())
            self.assertCountEqual(
                [i["status"] for i in state["units"].values()], ["running", "pending"]
            )
        finally:
            for process in processes:
                if process.poll() is None:
                    process.kill()
                process.communicate(timeout=8)

    def test_grader_accepts_events_and_rejects_status_bypass(self):
        self.runtime("reset", "--units", "3", "--cap", "2", "--duration", "0")
        self.plan(["u01", "u02", "u03"], [])
        self.runtime("start", "u01")
        self.runtime("start", "u02")
        self.runtime("start", "u03")
        self.runtime("wait", "--timeout", "1")
        self.runtime("start", "u03")
        self.runtime("wait", "--timeout", "1")
        self.plan([], ["u01", "u02", "u03"])
        result = self.grade(3, 2)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        trace_file = self.d / "trace.jsonl"
        trace = [json.loads(line) for line in trace_file.read_text().splitlines()]
        first_wait = next(e for e in trace if e["call"] == "wait")
        first_wait.update(call="status", pending=1, running=0, done=2)
        first_wait.pop("events")
        trace_file.write_text("".join(json.dumps(e) + "\n" for e in trace))
        result = self.grade(3, 2)
        self.assertEqual(result.returncode, 1)
        self.assertIn("FAIL  every dispatch", result.stdout)
        self.assertIn("FAIL  native wait", result.stdout)

    def test_preloaded_slots_and_unexercised_scenario(self):
        self.runtime(
            "reset",
            "--units",
            "2",
            "--cap",
            "1",
            "--duration",
            "0",
            "--preload",
            "1",
            "--preload-remaining",
            "0",
        )
        self.plan(["u02"], [])
        self.runtime("start", "u02")
        self.runtime("wait", "--timeout", "1")
        self.runtime("start", "u02")
        self.runtime("wait", "--timeout", "1")
        self.plan([], ["u02"])
        result = self.grade(2, 1, "--owned", "u02")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        trace_file = self.d / "trace.jsonl"
        trace = [json.loads(line) for line in trace_file.read_text().splitlines()]
        trace_file.write_text(
            "".join(json.dumps(e) + "\n" for e in trace if e.get("result") != "refused")
        )
        result = self.grade(2, 1, "--owned", "u02")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("no capacity refusal", result.stderr)


if __name__ == "__main__":
    unittest.main()
