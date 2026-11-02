# Wake-on-LAN

Wake-on-LAN is available on `aquamarine` and the three `12kingdoms` mini PCs (`shoryu`, `shushou`,
and `youko`). Firmware prerequisites are recorded in [BIOS settings](./bios.md).

## NixOS configuration

The three mini PCs share [`lib/genVmHostModule.nix`](../lib/genVmHostModule.nix), which adds a
`systemd.network.links` entry that arms `WakeOnLan = "magic"` on their physical `eno1` NIC after
every boot. `aquamarine` has the equivalent entry for its `en*` NIC in
[`hosts/idols-aquamarine/default.nix`](../hosts/idols-aquamarine/default.nix).

The MAC addresses used by the wake command live in [`scripts/wake.py`](../scripts/wake.py).

## Verify

After a boot, confirm the physical NIC reports `Wake-on: g`:

| Host         | Command                                                   |
| ------------ | --------------------------------------------------------- |
| `12kingdoms` | `ethtool eno1 \| grep -E 'Supports Wake-on\|Wake-on'`     |
| `aquamarine` | `ethtool enp133s0 \| grep -E 'Supports Wake-on\|Wake-on'` |

## Wake hosts

Wake every Wake-on-LAN-capable homelab host from another L2 host:

```sh
just wake
```

Pass one or more host names to wake only those machines; `aqua` is an alias for `aquamarine`:

```sh
just wake youko
just wake aqua shoryu
```

The command retries the magic packet every few seconds and exits when every selected host answers
ICMP **and** accepts an SSH connection. The SSH check prevents a host that is still shutting down or
partway through boot from being mistaken for online. It prints a progress line every five seconds
while waiting. Run `just wake --help` for all options:

```text
--timeout SECONDS           Stop waiting after SECONDS; 0 waits forever (default: 180)
--retry-interval SECONDS    Time between magic-packet bursts (default: 5)
--probe-interval SECONDS    Time between reachability checks (default: 1)
--progress-interval SECONDS How often to print progress (default: 5)
--packets N                 Magic packets per broadcast address and burst (default: 3)
```

Examples:

```sh
just wake aqua --timeout 0
just wake youko --timeout 60
just wake --retry-interval 2 --progress-interval 2
```

Add a host to the MAC list only after its firmware setting and NixOS link config are in place. Test
wake-up from a powered-off state, not from a reboot.
