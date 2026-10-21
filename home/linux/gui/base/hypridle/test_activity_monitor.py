"""Regression tests for the hypridle activity policy and device lifecycle."""

import argparse
import json
import os
import sys
import time
from pathlib import Path
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

import activity_monitor as monitor


class StateTests(unittest.TestCase):
    def test_activity_threshold_and_heartbeat_boundary(self):
        state = {"heartbeat": 100, "last_activity": 80}
        self.assertTrue(monitor.blocked(state, 21, 100))
        self.assertFalse(monitor.blocked(state, 20, 100))
        self.assertTrue(monitor.blocked(state, 100, 129.999))
        self.assertFalse(monitor.blocked(state, 100, 130))

    def test_invalid_and_future_state_never_blocks(self):
        for state in [
            None, [], {}, {"heartbeat": 100, "last_activity": None},
            {"heartbeat": 101, "last_activity": 90},
            {"heartbeat": 99, "last_activity": 100},
            {"heartbeat": 100, "last_activity": -1},
            {"heartbeat": True, "last_activity": 0},
            {"heartbeat": 100, "last_activity": float("nan")},
            {"heartbeat": float("inf"), "last_activity": 99},
            {"heartbeat": "100", "last_activity": 99},
        ]:
            with self.subTest(state=state):
                self.assertFalse(monitor.blocked(state, 1200, 100))

    def test_state_publication_and_missing_corrupt_recovery(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "activity" / "state.json"
            with self.assertLogs(monitor.LOG, level="WARNING"):
                self.assertEqual(monitor.check(path, 20, 100), 0)
            monitor.write_state(path, None, 100)
            self.assertEqual(monitor.check(path, 20, 100), 0)
            monitor.write_state(path, 90, 100)
            self.assertEqual(monitor.check(path, 20, 100), 1)
            self.assertEqual(list(path.parent.iterdir()), [path])
            self.assertEqual(path.stat().st_mode & 0o777, 0o600)
            path.write_text("{broken")
            with self.assertLogs(monitor.LOG, level="WARNING"):
                self.assertEqual(monitor.check(path, 20, 100), 0)
            monitor.write_state(path, 100, 100)
            self.assertEqual(json.loads(path.read_text())["heartbeat"], 100)

    def test_cli_exit_statuses(self):
        with tempfile.TemporaryDirectory() as runtime:
            path = Path(runtime) / "hypridle-activity" / "state.json"
            command = [sys.executable, "-B", monitor.__file__, "check", "--timeout", "1200"]
            env = dict(os.environ, XDG_RUNTIME_DIR=runtime)
            now = time.monotonic()
            for activity, heartbeat, expected in [
                (now, now, 1), (now - 1201, now, 0),
                (now, now - 31, 0), (None, now, 0),
            ]:
                monitor.write_state(path, activity, heartbeat)
                result = subprocess.run(command, env=env, capture_output=True, timeout=5)
                self.assertEqual(result.returncode, expected, result.stderr)

    def test_daemon_startup_has_no_fake_activity(self):
        selector = Mock()
        selector.select.side_effect = KeyboardInterrupt
        manager = Mock()
        manager.__enter__ = Mock(return_value=selector)
        manager.__exit__ = Mock(return_value=False)
        with tempfile.TemporaryDirectory() as runtime:
            path = Path(runtime) / "state.json"
            with (
                patch.dict(sys.modules, {"evdev": Mock(), "pyudev": Mock()}),
                patch.object(monitor.selectors, "DefaultSelector", return_value=manager),
                patch.object(monitor, "Joysticks"),
                patch.object(monitor, "media_active", return_value=False),
                patch.object(monitor.signal, "signal"),
                self.assertRaises(KeyboardInterrupt),
            ):
                monitor.daemon(path)
            self.assertIsNone(json.loads(path.read_text())["last_activity"])

    def test_first_gamepad_event_is_published_before_next_poll(self):
        selector = Mock()
        selector.select.side_effect = [[(SimpleNamespace(data="pad"), 1)], KeyboardInterrupt]
        manager = Mock()
        manager.__enter__ = Mock(return_value=selector)
        manager.__exit__ = Mock(return_value=False)
        with tempfile.TemporaryDirectory() as runtime:
            path = Path(runtime) / "state.json"
            with (
                patch.dict(sys.modules, {"evdev": Mock(), "pyudev": Mock()}),
                patch.object(monitor.selectors, "DefaultSelector", return_value=manager),
                patch.object(monitor, "Joysticks") as joysticks,
                patch.object(monitor, "media_active", return_value=False),
                patch.object(monitor.time, "monotonic", return_value=100),
                patch.object(monitor.signal, "signal"),
                self.assertRaises(KeyboardInterrupt),
            ):
                joysticks.return_value.read.return_value = True
                monitor.daemon(path)
            self.assertEqual(json.loads(path.read_text())["last_activity"], 100)

    def test_timeout_validation(self):
        for value in ["0", "-1", "nan", "inf"]:
            with self.subTest(value=value), self.assertRaises(argparse.ArgumentTypeError):
                monitor.positive_seconds(value)
        self.assertEqual(monitor.positive_seconds("20"), 20)


class AudioTests(unittest.TestCase):
    def setUp(self):
        monitor._FAILURES.clear()

    def test_error_log_deduplication_and_recovery(self):
        with self.assertLogs(monitor.LOG, level="WARNING") as logs:
            monitor.report_failure("audio", "unavailable")
            monitor.report_failure("audio", "unavailable")
        self.assertEqual(len(logs.output), 1)
        monitor.recovered("audio")
        with self.assertLogs(monitor.LOG, level="WARNING"):
            monitor.report_failure("audio", "unavailable")

    def test_pactl_string_client_fixture(self):
        self.assertTrue(monitor.audio_active([
            {"corked": False, "client": "389", "mute": False}
        ]))
        for client in ["4294967295", "n/a", "", "-1", "1.0", " 1", "+1"]:
            with self.subTest(client=client):
                self.assertFalse(monitor.audio_active([{"corked": False, "client": client}]))

    def test_uncorked_valid_client_only(self):
        self.assertTrue(monitor.audio_active([{"corked": False, "client": 0}]))
        for stream in [
            {}, {"corked": True, "client": 1}, {"corked": "false", "client": 1},
            {"corked": False, "client": None}, {"corked": False, "client": -1},
            {"corked": False, "client": 0xFFFFFFFF},
            {"corked": False, "client": True},
        ]:
            with self.subTest(stream=stream):
                self.assertFalse(monitor.audio_active([stream]))
        self.assertFalse(monitor.audio_active([]))
        with self.assertRaises(ValueError):
            monitor.audio_active({})

    def test_mpris_requires_exact_playing_status(self):
        self.assertTrue(monitor.playing("Paused\nPlaying\n"))
        self.assertFalse(monitor.playing("Not Playing\nPaused\nStopped\n"))

    @patch.object(monitor.subprocess, "run")
    def test_timeout_does_not_hide_other_media_source(self, run):
        run.side_effect = [
            subprocess.TimeoutExpired("pactl", 2),
            SimpleNamespace(returncode=0, stdout="Playing\n"),
        ]
        with self.assertLogs(monitor.LOG, level="WARNING"):
            self.assertTrue(monitor.media_active())
        for call in run.call_args_list:
            self.assertEqual(call.kwargs["timeout"], monitor.COMMAND_TIMEOUT)

    @patch.object(monitor.subprocess, "run")
    def test_failed_probe_can_recover_next_poll(self, run):
        run.side_effect = [
            FileNotFoundError("pactl"), SimpleNamespace(returncode=1, stdout=""),
            SimpleNamespace(stdout='[{"corked": false, "client": 1}]'),
            SimpleNamespace(returncode=1, stdout=""),
        ]
        with self.assertLogs(monitor.LOG, level="WARNING"):
            self.assertFalse(monitor.media_active())
        self.assertTrue(monitor.media_active())


class GamepadTests(unittest.TestCase):
    def active(self, kind, code, value, minimum=-32768, maximum=32767, flat=0):
        return monitor.gamepad_active(
            SimpleNamespace(type=kind, code=code, value=value),
            lambda _: SimpleNamespace(min=minimum, max=maximum, flat=flat),
        )

    def test_buttons_syn_and_unrelated_events(self):
        self.assertTrue(self.active(1, 304, 1))
        self.assertTrue(self.active(1, 304, 2))
        self.assertFalse(self.active(1, 304, 0))
        self.assertFalse(self.active(0, 0, 1))
        self.assertFalse(self.active(4, 0, 1))
        self.assertFalse(self.active(3, 40, 100))

    def test_center_drift_and_unsigned_sticks(self):
        self.assertFalse(self.active(3, 0, 1000))
        self.assertTrue(self.active(3, 0, -20000))
        self.assertTrue(self.active(3, 4, 20000))
        self.assertFalse(self.active(3, 0, 128, 0, 255))
        self.assertTrue(self.active(3, 0, 220, 0, 255))
        self.assertFalse(self.active(3, 0, 15000, flat=20000))

    def test_hat_trigger_and_invalid_axis(self):
        self.assertFalse(self.active(3, 16, 0))
        self.assertTrue(self.active(3, 16, -1))
        self.assertFalse(self.active(3, 2, 2, 0, 255))
        self.assertTrue(self.active(3, 2, 100, 0, 255))
        self.assertFalse(self.active(3, 0, 1, 0, 0))

    def test_reconcile_unplug_and_reconnect_without_grabbing(self):
        context, selector, device = Mock(), Mock(), Mock()
        node = Mock(device_node="/dev/input/event7")
        node.get.return_value = "1"
        context.list_devices.return_value = [node]
        device.fd = 7
        factory = Mock(return_value=device)
        joysticks = monitor.Joysticks(context, factory, selector)
        joysticks.reconcile()
        device.grab.assert_not_called()
        joysticks.reconcile()
        factory.assert_called_once_with("/dev/input/event7")
        device.read.return_value = [SimpleNamespace(type=0, code=0, value=0)]
        self.assertFalse(joysticks.read(node.device_node))
        device.read.return_value = [SimpleNamespace(type=1, code=304, value=1)]
        self.assertTrue(joysticks.read(node.device_node))
        device.read.side_effect = OSError("unplugged")
        self.assertFalse(joysticks.read(node.device_node))
        self.assertEqual(joysticks.devices, {})
        device.close.assert_called_once()
        joysticks.reconcile()
        self.assertEqual(factory.call_count, 2)
        context.list_devices.return_value = []
        joysticks.reconcile()
        self.assertEqual(joysticks.devices, {})


if __name__ == "__main__":
    unittest.main()
