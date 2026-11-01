#!/usr/bin/env python3
"""Wake every homelab host whose NixOS config arms Wake-on-LAN."""

from __future__ import annotations

import socket
import sys

# Keep this list limited to hosts that actually set Wake-on: g in NixOS.
# Add a host here only after its WoL service and BIOS setting are in place.
HOSTS = {
    "aquamarine": "8c:32:23:36:81:84",
}
BROADCASTS = ("192.168.5.255", "255.255.255.255")
PORT = 9
PACKETS = 3


def magic_packet(mac: str) -> bytes:
    octets = bytes.fromhex(mac.replace(":", ""))
    if len(octets) != 6:
        raise ValueError(f"invalid MAC: {mac}")
    return b"\xff" * 6 + octets * 16


def main() -> int:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    failed = False

    for host, mac in HOSTS.items():
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
