# Wake-on-LAN

Wake-on-LAN is available on `aquamarine` and the three `12kingdoms` mini PCs (`shoryu`, `shushou`,
and `youko`). Firmware prerequisites are recorded in [BIOS settings](./bios.md).

## NixOS configuration

The three mini PCs share [`lib/genVmHostModule.nix`](../lib/genVmHostModule.nix), which adds a
`systemd.network.links` entry that arms `WakeOnLan = "magic"` on their physical `eno1` NIC after
every boot. `aquamarine` has the equivalent entry for its `en*` NIC in
[`hosts/idols-aquamarine/default.nix`](../hosts/idols-aquamarine/default.nix).

The MAC addresses used by the wake command live in
[`scripts/wake-homelab.py`](../scripts/wake-homelab.py).

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

Add a host to the MAC list only after its firmware setting and NixOS link config are in place. Test
wake-up from a powered-off state, not from a reboot.
