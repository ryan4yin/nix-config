#!/usr/bin/env python3
"""Wake selected homelab hosts, defaulting to every WoL-capable host."""

from __future__ import annotations

import argparse
import socket
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

# Keep this list limited to hosts that actually set Wake-on: g in NixOS.
# Add a host here only after its WoL service and BIOS setting are in place.
HOSTS = {
    "aquamarine": ("8c:32:23:36:81:84", "192.168.5.101"),
    "shoryu": ("70:70:fc:01:1b:56", "192.168.5.181"),
    "shushou": ("58:47:ca:70:0d:72", "192.168.5.182"),
    "youko": ("70:70:fc:01:00:44", "192.168.5.183"),
}
ALIASES = {
    "aqua": "aquamarine",
}
BROADCASTS = ("192.168.5.255", "255.255.255.255")
PORT = 9
PACKETS_PER_ROUND = 3
RETRY_INTERVAL_SECONDS = 5.0
PROBE_INTERVAL_SECONDS = 1.0
PROGRESS_INTERVAL_SECONDS = 5.0
DEFAULT_TIMEOUT_SECONDS = 180.0


def magic_packet(mac: str) -> bytes:
    octets = bytes.fromhex(mac.replace(":", ""))
    if len(octets) != 6:
        raise ValueError(f"invalid MAC: {mac}")
    return b"\xff" * 6 + octets * 16


def is_online(ip: str) -> bool:
    """Return whether a host answers ICMP and has reached a usable SSH state.

    Requiring SSH prevents a host that is still shutting down, or only partway through boot,
    from being mistaken for online just because it still answers ping.
    """
    try:
        ping = subprocess.run(
            ["ping", "-c", "1", "-W", "1", ip],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=2,
            check=False,
        )
        if ping.returncode != 0:
            return False
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False

    try:
        with socket.create_connection((ip, 22), timeout=1):
            return True
    except OSError:
        return False


def select_hosts(names: list[str]) -> list[str]:
    if not names:
        return list(HOSTS)

    selected = []
    for name in names:
        host = ALIASES.get(name, name)
        if host not in HOSTS:
            known = ", ".join(sorted(HOSTS))
            aliases = ", ".join(f"{alias} -> {host}" for alias, host in ALIASES.items())
            raise ValueError(f"unknown host {name!r}; known hosts: {known}; aliases: {aliases}")
        if host not in selected:
            selected.append(host)
    return selected


def positive_float(value: str) -> float:
    number = float(value)
    if number <= 0:
        raise argparse.ArgumentTypeError("must be greater than zero")
    return number


def non_negative_float(value: str) -> float:
    number = float(value)
    if number < 0:
        raise argparse.ArgumentTypeError("must be zero or greater")
    return number


def positive_int(value: str) -> int:
    number = int(value)
    if number <= 0:
        raise argparse.ArgumentTypeError("must be greater than zero")
    return number


def main(argv: list[str] | None = None) -> int:
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
        type=non_negative_float,
        default=DEFAULT_TIMEOUT_SECONDS,
        metavar="SECONDS",
        help="stop waiting after this many seconds (default: 180; 0 waits forever)",
    )
    parser.add_argument(
        "--retry-interval",
        type=positive_float,
        default=RETRY_INTERVAL_SECONDS,
        metavar="SECONDS",
        help="time between magic-packet bursts for hosts still offline (default: 5)",
    )
    parser.add_argument(
        "--probe-interval",
        type=positive_float,
        default=PROBE_INTERVAL_SECONDS,
        metavar="SECONDS",
        help="time between reachability checks (default: 1)",
    )
    parser.add_argument(
        "--progress-interval",
        type=positive_float,
        default=PROGRESS_INTERVAL_SECONDS,
        metavar="SECONDS",
        help="how often to print a waiting-for progress line (default: 5)",
    )
    parser.add_argument(
        "--packets",
        type=positive_int,
        default=PACKETS_PER_ROUND,
        metavar="N",
        help="magic packets per broadcast address and burst (default: 3)",
    )
    args = parser.parse_args(argv)

    try:
        hosts = select_hosts(args.hosts)
    except ValueError as exc:
        parser.error(str(exc))

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    failed = False
    start = time.monotonic()
    attempts = {host: 0 for host in hosts}

    def elapsed() -> float:
        return time.monotonic() - start

    def send_packets(host: str) -> None:
        nonlocal failed
        attempts[host] += 1
        mac, _ = HOSTS[host]
        packet = magic_packet(mac)
        print(
            f"[{elapsed():5.1f}s] attempt {attempts[host]}: "
            f"sending {args.packets * len(BROADCASTS)} magic packets to {host} ({mac})",
            flush=True,
        )
        for _ in range(args.packets):
            for broadcast in BROADCASTS:
                try:
                    sock.sendto(packet, (broadcast, PORT))
                except OSError as exc:
                    print(f"  {broadcast}:{PORT}: {exc}", file=sys.stderr)
                    failed = True

    with ThreadPoolExecutor(max_workers=max(1, len(hosts))) as executor:
        initial = {executor.submit(is_online, HOSTS[host][1]): host for host in hosts}
        pending = set(hosts)
        for future in as_completed(initial):
            host = initial[future]
            if future.result():
                pending.remove(host)
                print(f"[{elapsed():5.1f}s] {host} is already online", flush=True)

        if not pending:
            return 0

        for host in sorted(pending):
            send_packets(host)
        last_sent = {host: time.monotonic() for host in pending}
        last_progress = time.monotonic()

        while pending:
            now = time.monotonic()
            if args.timeout > 0 and now - start >= args.timeout:
                print(
                    f"[{elapsed():5.1f}s] timed out waiting for: {', '.join(sorted(pending))}",
                    file=sys.stderr,
                )
                return 1

            probes = {executor.submit(is_online, HOSTS[host][1]): host for host in pending}
            for future in as_completed(probes):
                host = probes[future]
                if future.result():
                    pending.remove(host)
                    print(f"[{elapsed():5.1f}s] {host} is online", flush=True)

            if not pending:
                break

            now = time.monotonic()
            for host in sorted(pending):
                if now - last_sent[host] >= args.retry_interval:
                    send_packets(host)
                    last_sent[host] = now

            if now - last_progress >= args.progress_interval:
                status = ", ".join(
                    f"{host} (attempt {attempts[host]})" for host in sorted(pending)
                )
                print(f"[{elapsed():5.1f}s] still waiting for: {status}", flush=True)
                last_progress = now

            time.sleep(args.probe_interval)

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
