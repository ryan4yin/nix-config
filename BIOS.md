# BIOS Settings

Manual firmware settings are not managed by Nix. Record values that affect power use, remote wake,
and boot behavior here so they survive BIOS updates and hardware swaps.

Enter firmware setup with `Del` unless a host section says otherwise.

Last reviewed: 2026-11-02.

## `12kingdoms` mini PCs

Hosts: `shoryu` (MoreFine S500+), `shushou` (MinisForum UM560), `youko` (Beelink GTR5).

### Common settings

- `Advanced > CPU Configuration > PPC Adjustment (P-State)` = `PState 2` (full-range adjustment
  mode).
- `Advanced > AMD CBS > FCH Common Options > AC Power Loss Options`:
  - `AC Power Loss` = `Always On`
  - `SATA Controller` = `Disabled`
- Disable unused onboard devices where the firmware exposes them (for example `HDD` and WLAN
  options); none are in use on these hosts.

### Wake-on-LAN

The firmware path differs by model:

| Host      | Model            | Setting                                |
| --------- | ---------------- | -------------------------------------- |
| `shoryu`  | MoreFine S500+   | `Advanced > Network Stack` = `Enabled` |
| `shushou` | MinisForum UM560 | `Advanced > Resume on LAN` = `Enabled` |
| `youko`   | Beelink GTR5     | `Advanced > Network Stack` = `Enabled` |

The firmware side only exposes the wake path. NixOS arms the physical NIC through the shared
[`lib/genVmHostModule.nix`](./lib/genVmHostModule.nix) `systemd.network.links` entry. Verify after a
boot with:

```sh
ethtool eno1 | grep -E 'Supports Wake-on|Wake-on'
```

The link must report `Wake-on: g`. Wake all four homelab machines from another L2 host with:

```sh
just wake-homelab
```

Test wake-up from a powered-off state, not from a reboot.

## `aquamarine`

Board: Colorful CVN Z890 ARK FROZEN V20 (BIOS 1013). Settings changed on 2026-11-01.

| Page             | Setting                  | Value                                          |
| ---------------- | ------------------------ | ---------------------------------------------- |
| Home             | Performance mode         | Power-saving mode                              |
| Home             | Cooler                   | Intel default settings (lowers PL1/PL2 limits) |
| Home             | HD audio                 | Disabled                                       |
| Advanced > Power | RGB lighting             | Disabled                                       |
| Advanced > Power | Restore on AC power loss | Power on                                       |
| OC > Frequency   | Intel 200S Boost         | Disabled                                       |
| OC > Frequency   | Intel Default Settings   | Enabled                                        |

Wake-on-LAN is also required for the idle-suspend path:

- `Advanced > Power Setting > Wake By Lan` = `Enabled`.
- EUP must not cut standby power to the NIC.
- NixOS arms the RTL8125BG through `systemd.network.links`; see
  [`hosts/idols-aquamarine/README.md`](./hosts/idols-aquamarine/README.md#wake-on-lan).

Verify after boot:

```sh
ethtool enp133s0 | grep -E 'Supports Wake-on|Wake-on'
```
