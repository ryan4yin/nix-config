from __future__ import annotations

import io
import unittest

from scripts.wake import (
    Host,
    HostSelectionError,
    Reporter,
    WakeConfig,
    WakeSession,
    magic_packet,
    resolve_hosts,
)


class FakeClock:
    def __init__(self) -> None:
        self.now = 0.0

    def __call__(self) -> float:
        return self.now

    def sleep(self, seconds: float) -> None:
        self.now += seconds


class RecordingSender:
    def __init__(self) -> None:
        self.calls: list[tuple[str, int]] = []

    def __call__(self, host: Host, packets_per_broadcast: int) -> None:
        self.calls.append((host.name, packets_per_broadcast))


class SequenceProbe:
    def __init__(self, online_on_call: int) -> None:
        self._online_on_call = online_on_call
        self._calls = 0

    def __call__(self, _host: Host) -> bool:
        self._calls += 1
        return self._calls >= self._online_on_call


class MagicPacketTests(unittest.TestCase):
    def test_builds_standard_packet(self) -> None:
        mac = "8c:32:23:36:81:84"
        packet = magic_packet(mac)

        self.assertEqual(len(packet), 102)
        self.assertEqual(packet[:6], b"\xff" * 6)
        self.assertEqual(packet[6:], bytes.fromhex(mac.replace(":", "")) * 16)

    def test_rejects_invalid_mac(self) -> None:
        with self.assertRaises(ValueError):
            magic_packet("not-a-mac")


class ResolveHostsTests(unittest.TestCase):
    def setUp(self) -> None:
        self.hosts = {
            "alpha": Host("alpha", "00:00:00:00:00:01", "192.0.2.1"),
            "beta": Host("beta", "00:00:00:00:00:02", "192.0.2.2"),
        }

    def test_defaults_to_all_hosts(self) -> None:
        self.assertEqual(resolve_hosts([], hosts=self.hosts), list(self.hosts.values()))

    def test_resolves_alias_and_removes_duplicates(self) -> None:
        selected = resolve_hosts(
            ["a", "alpha", "beta"],
            hosts=self.hosts,
            aliases={"a": "alpha"},
        )
        self.assertEqual(selected, [self.hosts["alpha"], self.hosts["beta"]])

    def test_rejects_unknown_host(self) -> None:
        with self.assertRaises(HostSelectionError):
            resolve_hosts(["missing"], hosts=self.hosts, aliases={})


class WakeSessionTests(unittest.TestCase):
    def test_retries_until_host_is_online(self) -> None:
        clock = FakeClock()
        sender = RecordingSender()
        stdout = io.StringIO()
        stderr = io.StringIO()
        reporter = Reporter(stream=stdout, error_stream=stderr, clock=clock)
        host = Host("test", "00:00:00:00:00:01", "192.0.2.1")
        config = WakeConfig(
            timeout=30,
            retry_interval=5,
            probe_interval=1,
            progress_interval=5,
            packets_per_broadcast=2,
        )
        session = WakeSession(
            [host],
            config,
            reporter,
            sender=sender,
            probe=SequenceProbe(online_on_call=10),
            clock=clock,
            sleep=clock.sleep,
        )

        self.assertEqual(session.run(), 0)
        self.assertEqual(sender.calls, [("test", 2), ("test", 2)])
        output = stdout.getvalue()
        self.assertIn("attempt 2", output)
        self.assertIn("still waiting for: test (attempt 2, 192.0.2.1)", output)
        self.assertIn("test is online", output)

    def test_exits_immediately_when_host_is_already_online(self) -> None:
        clock = FakeClock()
        sender = RecordingSender()
        reporter = Reporter(
            stream=io.StringIO(), error_stream=io.StringIO(), clock=clock
        )
        host = Host("test", "00:00:00:00:00:01", "192.0.2.1")
        session = WakeSession(
            [host],
            WakeConfig(),
            reporter,
            sender=sender,
            probe=lambda _host: True,
            clock=clock,
            sleep=clock.sleep,
        )

        self.assertEqual(session.run(), 0)
        self.assertEqual(sender.calls, [])

    def test_times_out_when_host_never_comes_online(self) -> None:
        clock = FakeClock()
        sender = RecordingSender()
        stdout = io.StringIO()
        stderr = io.StringIO()
        reporter = Reporter(stream=stdout, error_stream=stderr, clock=clock)
        host = Host("test", "00:00:00:00:00:01", "192.0.2.1")
        session = WakeSession(
            [host],
            WakeConfig(timeout=3, retry_interval=5),
            reporter,
            sender=sender,
            probe=lambda _host: False,
            clock=clock,
            sleep=clock.sleep,
        )

        self.assertEqual(session.run(), 1)
        self.assertIn("timed out waiting for: test", stderr.getvalue())


if __name__ == "__main__":
    unittest.main()
