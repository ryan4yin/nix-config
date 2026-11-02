#!/usr/bin/env python3
"""Wake homelab hosts over Wake-on-LAN and wait until they are reachable."""

from __future__ import annotations

import argparse
import socket
import subprocess
import sys
import time
from collections.abc import Callable, Mapping, Sequence
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from typing import Self, TextIO

BROADCAST_ADDRESSES = ("192.168.5.255", "255.255.255.255")
WOL_PORT = 9
SSH_PORT = 22
PING_WAIT_SECONDS = 1
PING_TIMEOUT_SECONDS = PING_WAIT_SECONDS + 1
SSH_TIMEOUT_SECONDS = 1.0

DEFAULT_TIMEOUT_SECONDS = 180.0
DEFAULT_RETRY_INTERVAL_SECONDS = 5.0
DEFAULT_PROBE_INTERVAL_SECONDS = 1.0
DEFAULT_PROGRESS_INTERVAL_SECONDS = 5.0
DEFAULT_PACKETS_PER_BROADCAST = 3


@dataclass(frozen=True, slots=True)
class Host:
    """A Wake-on-LAN-capable host."""

    name: str
    mac: str
    ip: str


# Keep this list limited to hosts that actually set Wake-on: g in NixOS.
# Add a host here only after its firmware setting and NixOS link config exist.
HOSTS: Mapping[str, Host] = {
    "aquamarine": Host("aquamarine", "8c:32:23:36:81:84", "192.168.5.101"),
    "shoryu": Host("shoryu", "70:70:fc:01:1b:56", "192.168.5.181"),
    "shushou": Host("shushou", "58:47:ca:70:0d:72", "192.168.5.182"),
    "youko": Host("youko", "70:70:fc:01:00:44", "192.168.5.183"),
}

ALIASES: Mapping[str, str] = {
    "aqua": "aquamarine",
}


@dataclass(frozen=True, slots=True)
class WakeConfig:
    """Timing and packet settings for one wake run."""

    timeout: float = DEFAULT_TIMEOUT_SECONDS
    retry_interval: float = DEFAULT_RETRY_INTERVAL_SECONDS
    probe_interval: float = DEFAULT_PROBE_INTERVAL_SECONDS
    progress_interval: float = DEFAULT_PROGRESS_INTERVAL_SECONDS
    packets_per_broadcast: int = DEFAULT_PACKETS_PER_BROADCAST


class HostSelectionError(ValueError):
    """Raised when a requested host name is unknown."""


class Reporter:
    """Print timestamped progress messages."""

    def __init__(
        self,
        *,
        stream: TextIO | None = None,
        error_stream: TextIO | None = None,
        clock: Callable[[], float] = time.monotonic,
    ) -> None:
        self._stream = stream if stream is not None else sys.stdout
        self._error_stream = error_stream if error_stream is not None else sys.stderr
        self._clock = clock
        self._started_at = clock()

    def elapsed(self) -> float:
        return self._clock() - self._started_at

    def info(self, message: str) -> None:
        print(f"[{self.elapsed():5.1f}s] {message}", file=self._stream, flush=True)

    def error(self, message: str) -> None:
        print(
            f"[{self.elapsed():5.1f}s] {message}", file=self._error_stream, flush=True
        )


class MagicPacketSender:
    """Send Wake-on-LAN magic packets over a UDP broadcast socket."""

    def __init__(
        self,
        *,
        broadcasts: Sequence[str] = BROADCAST_ADDRESSES,
        port: int = WOL_PORT,
    ) -> None:
        self._broadcasts = tuple(broadcasts)
        self._port = port
        self._socket: socket.socket | None = None

    def __enter__(self) -> Self:
        self._socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self._socket.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        return self

    def __exit__(self, *_exc_info: object) -> None:
        if self._socket is not None:
            self._socket.close()
            self._socket = None

    def send(self, host: Host, packets_per_broadcast: int) -> None:
        """Send one magic-packet burst."""
        if self._socket is None:
            raise RuntimeError("sender must be used as a context manager")

        packet = magic_packet(host.mac)
        for _ in range(packets_per_broadcast):
            for broadcast in self._broadcasts:
                self._socket.sendto(packet, (broadcast, self._port))


@dataclass(slots=True)
class _HostState:
    host: Host
    attempts: int = 0
    last_sent_at: float = 0.0


class WakeSession:
    """Retry magic packets until all hosts are online or the timeout expires."""

    def __init__(
        self,
        hosts: Sequence[Host],
        config: WakeConfig,
        reporter: Reporter,
        *,
        sender: Callable[[Host, int], None],
        probe: Callable[[Host], bool] | None = None,
        clock: Callable[[], float] = time.monotonic,
        sleep: Callable[[float], None] = time.sleep,
    ) -> None:
        self._states = {host.name: _HostState(host) for host in hosts}
        self._config = config
        self._reporter = reporter
        self._sender = sender
        self._probe = probe or host_online
        self._clock = clock
        self._sleep = sleep
        self._send_failed = False
        self._last_progress_at = 0.0

    def run(self) -> int:
        self._probe_pending(initial=True)
        if not self._states:
            return 0

        for name in sorted(self._states):
            self._send(self._states[name])
        self._reporter.info(
            f"waking {self._describe_pending()}; retrying every "
            f"{self._config.retry_interval:g}s until online"
        )
        self._last_progress_at = self._clock()

        while self._states:
            if self._timed_out():
                names = ", ".join(sorted(self._states))
                self._reporter.error(f"timed out waiting for: {names}")
                return 1

            self._probe_pending(initial=False)
            if not self._states:
                break

            self._retry_pending()
            self._report_progress()
            self._sleep(self._config.probe_interval)

        return 1 if self._send_failed else 0

    def _timed_out(self) -> bool:
        return (
            self._config.timeout > 0
            and self._reporter.elapsed() >= self._config.timeout
        )

    def _probe_pending(self, *, initial: bool) -> None:
        states = list(self._states.values())
        if not states:
            return

        with ThreadPoolExecutor(max_workers=len(states)) as executor:
            futures = {
                executor.submit(self._probe, state.host): state for state in states
            }
            for future in as_completed(futures):
                state = futures[future]
                if not future.result():
                    continue

                self._states.pop(state.host.name, None)
                if initial:
                    self._reporter.info(f"{state.host.name} is already online")
                else:
                    self._reporter.info(
                        f"{state.host.name} is online after {state.attempts} magic-packet bursts"
                    )

    def _send(self, state: _HostState) -> None:
        state.attempts += 1
        try:
            self._sender(state.host, self._config.packets_per_broadcast)
        except OSError as exc:
            self._send_failed = True
            self._reporter.error(
                f"failed to send magic packets to {state.host.name}: {exc}"
            )
            return

        state.last_sent_at = self._clock()

    def _retry_pending(self) -> None:
        now = self._clock()
        for name in sorted(self._states):
            state = self._states[name]
            if now - state.last_sent_at >= self._config.retry_interval:
                self._send(state)

    def _report_progress(self) -> None:
        now = self._clock()
        if now - self._last_progress_at < self._config.progress_interval:
            return

        self._reporter.info(f"still waiting for: {self._describe_pending()}")
        self._last_progress_at = now

    def _describe_pending(self) -> str:
        return ", ".join(
            f"{name} (attempt {state.attempts}, {state.host.ip})"
            for name, state in sorted(self._states.items())
        )


def magic_packet(mac: str) -> bytes:
    """Build the standard 102-byte Wake-on-LAN magic packet."""
    try:
        mac_bytes = bytes.fromhex(mac.replace(":", ""))
    except ValueError as exc:
        raise ValueError(f"invalid MAC address: {mac!r}") from exc

    if len(mac_bytes) != 6:
        raise ValueError(f"invalid MAC address: {mac!r}")

    return b"\xff" * 6 + mac_bytes * 16


def resolve_hosts(
    names: Sequence[str],
    *,
    hosts: Mapping[str, Host] = HOSTS,
    aliases: Mapping[str, str] = ALIASES,
) -> list[Host]:
    """Resolve CLI host names and aliases, preserving order and removing duplicates."""
    if not names:
        return list(hosts.values())

    selected: dict[str, Host] = {}
    for requested_name in names:
        canonical_name = aliases.get(requested_name, requested_name)
        try:
            host = hosts[canonical_name]
        except KeyError as exc:
            known = ", ".join(sorted(hosts))
            alias_help = ", ".join(
                f"{alias} -> {target}" for alias, target in aliases.items()
            )
            raise HostSelectionError(
                f"unknown host {requested_name!r}; known hosts: {known}; aliases: {alias_help}"
            ) from exc
        selected[host.name] = host

    return list(selected.values())


def host_online(host: Host) -> bool:
    """Return whether a host answers ICMP and has reached a usable SSH state.

    Requiring SSH prevents a host that is still shutting down, or partway through boot, from being
    mistaken for online just because it still answers ping.
    """
    return _ping(host.ip) and _ssh_port_open(host.ip)


def _ping(ip: str) -> bool:
    try:
        result = subprocess.run(
            ["ping", "-c", "1", "-W", str(PING_WAIT_SECONDS), ip],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=PING_TIMEOUT_SECONDS + 1,
            check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False
    return result.returncode == 0


def _ssh_port_open(ip: str) -> bool:
    try:
        with socket.create_connection((ip, SSH_PORT), timeout=SSH_TIMEOUT_SECONDS):
            return True
    except OSError:
        return False


def _positive_float(value: str) -> float:
    number = float(value)
    if number <= 0:
        raise argparse.ArgumentTypeError("must be greater than zero")
    return number


def _non_negative_float(value: str) -> float:
    number = float(value)
    if number < 0:
        raise argparse.ArgumentTypeError("must be zero or greater")
    return number


def _positive_int(value: str) -> int:
    number = int(value)
    if number <= 0:
        raise argparse.ArgumentTypeError("must be greater than zero")
    return number


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="just wake",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=(
            "Wake selected homelab hosts, keep retrying the magic packet, and exit when every "
            "selected host answers. With no host arguments, wake every WoL-capable host."
        ),
        epilog=(
            "Examples:\n"
            "  just wake\n"
            "  just wake aqua youko\n"
            "  just wake shoryu --timeout 0 --progress-interval 2"
        ),
    )
    parser.add_argument(
        "hosts",
        nargs="*",
        metavar="HOST",
        help="hosts to wake (default: all); use 'aqua' as an alias for aquamarine",
    )
    parser.add_argument(
        "--timeout",
        type=_non_negative_float,
        default=DEFAULT_TIMEOUT_SECONDS,
        metavar="SECONDS",
        help="stop waiting after this many seconds (default: 180; 0 waits forever)",
    )
    parser.add_argument(
        "--retry-interval",
        type=_positive_float,
        default=DEFAULT_RETRY_INTERVAL_SECONDS,
        metavar="SECONDS",
        help="time between magic-packet bursts for hosts still offline (default: 5)",
    )
    parser.add_argument(
        "--probe-interval",
        type=_positive_float,
        default=DEFAULT_PROBE_INTERVAL_SECONDS,
        metavar="SECONDS",
        help="time between reachability checks (default: 1)",
    )
    parser.add_argument(
        "--progress-interval",
        type=_positive_float,
        default=DEFAULT_PROGRESS_INTERVAL_SECONDS,
        metavar="SECONDS",
        help="how often to print a waiting-for progress line (default: 5)",
    )
    parser.add_argument(
        "--packets",
        type=_positive_int,
        default=DEFAULT_PACKETS_PER_BROADCAST,
        metavar="N",
        help="magic packets per broadcast address and burst (default: 3)",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        hosts = resolve_hosts(args.hosts)
    except HostSelectionError as exc:
        parser.error(str(exc))

    config = WakeConfig(
        timeout=args.timeout,
        retry_interval=args.retry_interval,
        probe_interval=args.probe_interval,
        progress_interval=args.progress_interval,
        packets_per_broadcast=args.packets,
    )

    reporter = Reporter()
    with MagicPacketSender() as sender:
        return WakeSession(hosts, config, reporter, sender=sender.send).run()


if __name__ == "__main__":
    sys.exit(main())
