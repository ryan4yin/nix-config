#!/usr/bin/env python3
"""Wake selected homelab hosts, defaulting to every WoL-capable host."""

from __future__ import annotations

import argparse
import socket
import sys

# Keep this list limited to hosts that actually set Wake-on: g in NixOS.
# Add a host here only after its WoL service and BIOS setting are in place.
HOSTS = {
    "aquamarine": "8c:32:23:36:81:84",
    "shoryu": "70:70:fc:01:1b:56",
    "shushou": "58:47:ca:70:0d:72",
    "youko": "70:70:fc:01:00:44",
}
ALIASES = {
    "aqua": "aquamarine",
}
BROADCASTS = ("192.168.5.255", "255.255.255.255")
PORT = 9
PACKETS = 3


def magic_packet(mac: str) -> bytes:
    octets = bytes.fromhex(mac.replace(":", ""))
    if len(octets) != 6:
        raise ValueError(f"invalid MAC: {mac}")
    return b"\xff" * 6 + octets * 16


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


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="just wake",
        description="Wake selected homelab hosts, or every host when none are given.",
    )
    parser.add_argument(
        "hosts",
        nargs="*",
        metavar="HOST",
        help="hosts to wake (default: all); use 'aqua' as an alias for aquamarine",
    )
    args = parser.parse_args(argv)

    try:
        hosts = select_hosts(args.hosts)
    except ValueError as exc:
        parser.error(str(exc))

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    failed = False

    for host in hosts:
        mac = HOSTS[host]
        packet = magic_packet(mac)
        print(f"waking {host} ({mac})")
        for _ in range(PACKETS):
            for broadcast in BROADCASTS:
                try:
                    sock.sendto(packet, (broadcast, PORT))
                except OSError as exc:
                    print(f"  {broadcast}:{PORT}: {exc}", file=sys.stderr)
                    failed = True

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
