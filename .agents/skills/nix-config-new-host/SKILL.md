---
name: Nix Config New Host
description:
  Use when adding, renaming, or removing a NixOS, macOS, or MicroVM host in this repo. Covers the
  host directory, the outputs and networking wiring, secrets, and the tests that fail until the host
  is fully wired.
---

# Adding a host

A host is wired in four places in this repository plus the private secrets repository. Start by
copying the nearest existing analogue -
[hosts/README.md](../../../hosts/README.md#how-to-add-a-new-host) has the inventory and the file
list; this skill is the checklist and the traps.

## Core rules

1. **Copy the closest host.** Desktop, VM host, macOS, and aarch64 each have a different shape, and
   the differences are in the small files, not in `default.nix`.
2. **The configuration name, the directory name, and the hostname are three different things.**
   `hosts/idols-ai/` sets `hostName = "ai"`, and the desktop configuration is `ai-niri`. Decide this
   before wiring anything: `just niri` deploys `$(hostname)-niri`, and the `hostname` eval test
   encodes the relationship.
3. **Remote hosts deploy through Colmena**, which needs `tags`, `ssh-user`, and a reachable
   `targetHost`. A host with no Colmena output cannot be deployed remotely.
4. **A new host cannot decrypt secrets until its key is in the private repository.** That is a
   separate change, on a different host; see the `nix-config-secrets` skill.
5. **The shared security modules are not optional.** The `security-*` eval tests run against every
   configuration, so a host that misses one fails `just test` rather than failing in production.
6. **Build before you install.** `just test`, then `just eval-host <host>` and
   `just build-host <host>`. Nothing should be reformatted or flashed before that passes.

## 1. Pick the template

| New host                 | Copy from                                                                        |
| ------------------------ | -------------------------------------------------------------------------------- |
| Desktop workstation      | `hosts/idols-ai/` + `outputs/x86_64-linux/src/idols-ai.nix`                      |
| Homelab server / VM host | `hosts/12kingdoms-shoryu/` + `outputs/x86_64-linux/src/12kingdoms-shoryu.nix`    |
| Apple Silicon Linux      | `hosts/12kingdoms-shoukei/` + `outputs/aarch64-linux/src/12kingdoms-shoukei.nix` |
| macOS                    | `hosts/darwin-fern/` + `outputs/aarch64-darwin/src/fern.nix`                     |
| MicroVM guest            | not this path - guests are wired in the VM host's `microvm.nix`                  |

## 2. The host directory, `hosts/<dir>/`

`default.nix` imports `mylib.scanPaths ./`, so **every other `.nix` file in the directory is
auto-imported** - put host-specific modules there, and keep scratch files out of it.

- `default.nix` - `hostName`, the imports, and the host's modules.
- `hardware-configuration.nix` - generate it on the target (`nixos-generate-config`) after
  partitioning; do not hand-write or copy it from another machine.
- `disko-fs*.nix` - the declarative disk layout. Running it **destroys the disks**, so it is an
  install-time action only.
- `preservation.nix`, `restic.nix`, `service-user-ids.nix`, `secureboot.nix` - only where the host
  needs them.
- `README.md` - record the disk device and the exact install command, the way
  `hosts/idols-ai/README.md` does.

## 3. The Home Manager side

`home/hosts/linux/<name>.nix` or `home/hosts/darwin/<name>.nix`, referenced from the host's
`home-modules`. Skip it for a host with no Home Manager configuration, and leave the `home-modules`
list empty rather than pointing at a file that does not exist.

## 4. The outputs wiring, `outputs/<system>/src/<name>.nix`

One file per host, defining:

- `nixosConfigurations.<name>` - for a desktop, `<hostname>-niri` (see `idols-ai.nix`).
- `colmena.<name>` - `tags`, `ssh-user = "root"`, and `targetHost` from
  `myvars.networking.hostsAddr.<name>.ipv4`. Use the IP when the host's DNS name is not resolvable
  yet, which is normal right after a hostname change.
- `packages.<name>` - the install ISO.

Keep the leading `args` comment in a copied file: haumea passes arguments lazily, and the unused
ones are still required.

## 5. Networking, `vars/networking.nix`

Add `hostsAddr.<name> = { iface; ipv4; }` for a host on the home LAN. This one entry drives static
addressing (`hostsInterface`), the `Host` aliases used for remote builders, and `known_hosts`, so a
wrong interface name breaks the host's network at activation. Skip it for a mobile or DHCP host.

## 6. Secrets, in the private repository

Add the new host's `/etc/ssh/ssh_host_ed25519_key.pub` to `secrets.nix`, rekey on a desktop, and
give the host only the groups it needs. Until this is done, the first activation fails on
decryption.

## 7. Tests that fail until the host is wired

Tests are directories with `expr.nix` and `expected.nix` (the `tests/<name>.nix` shape described in
`hosts/README.md` is out of date). The ones that speak about every configuration:

- `tests/hostname` - asserts `nixosConfigurations.<name>.config.networking.hostName == <name>`, with
  `ai-niri` as the one exception. A new `-niri` host needs a `specialExpected` entry.
- `tests/security-*` (`firewall`, `apparmor`, `container-groups`, `ssh-x11`, `k3s-kubeconfig`) -
  each asserts a policy for every configuration, so a new host must load the shared modules.
- `tests/kernel`, `tests/btrbk`, `tests/home-manager`, `tests/nix-system-features` - add a case when
  the host differs from the default.

`just test` must print `true`; exit code `0` with `false` is a failure.

## 8. Install and deploy

- First install: boot the ISO, partition with disko, install, then deploy normally. See
  [nixos-installer/README.md](../../../nixos-installer/README.md) and the host's own README.
- Remote host: `just col <tag>` or the host's own recipe, in `switch` mode for an ordinary change.
- The machine you are on: `just local` or `just niri`. These prompt for `sudo`, so the user runs
  them.
- VM hosts with the `br0` bridge: `boot` plus a reboot for anything that can drop the network. See
  [hosts/README.md](../../../hosts/README.md#deploying-vm-hosts).

## 9. Verify

- The activation command reporting success, then reachability: `ssh <host> true`, or a service check
  for the role the host plays.
- `systemctl --failed` and `journalctl -b -p err` on the new host.
- Secrets decrypted, checked by mode and owner only (see the `nix-config-secrets` skill).
- Pin service user/group ids in `service-user-ids.nix` **before** the host has state on disk; a uid
  that moves on a later rebuild orphans files it owns.

## Lessons from past changes

These all happened in this repository; they are the reason for the steps above.

- `69f77fec feat: new host - idols-akane, hardens VFAT /boot mounts (#245)` - a host addition lands
  with its own hardware quirks, not just a copied directory.
- `db82d2d8 feat: remove x86_64-darwin, add new nixos host on macbook pro m2` - hosts move between
  platforms, so a new host is also a check of `outputs/<system>/src/`.
- `9187e4d9 fix(youko): pin dynamically-allocated service uid/gid (#320)` - a dynamically allocated
  uid moved and stranded state; pin them early.
- `7ea1e6ae feat: idols-akane - add virtfs file sharing between host & guest` - host and guest
  wiring are separate changes even when they ship together.
