---
name: Nix Config New Host
description:
  Use when adding, renaming, or removing a NixOS, macOS, or MicroVM host in this repo. Covers the
  files to create, the outputs and networking wiring, secrets, the eval tests that fail until the
  host is fully wired, and the first install.
---

# Adding a host

Copy the closest existing host and change what differs. The current inventory and naming scheme are
in [hosts/README.md](../../../hosts/README.md).

## Core rules

1. **Three names, decided up front.** The directory (`hosts/idols-ai/`), the hostname
   (`hostName = "ai"`), and the configuration name (`ai-niri`) differ. Servers use the hostname as
   the configuration name; Niri desktops append `-niri`, because `just niri` deploys
   `$(hostname)-niri`. The `hostname` eval test encodes this.
2. **Secrets come from another repository.** The new host decrypts nothing until its host key is a
   recipient in `nix-secrets`; see the `nix-config-secrets` skill.
3. **The shared policy modules are not optional.** Several eval tests assert a policy for every
   configuration, so an under-wired host fails `just test` instead of failing in production.
4. **Build before you install.** `just test`, `just eval-host <name>`, and `just build-host <name>`
   pass before anything is partitioned or flashed. `disko` destroys the target disk.

## 1. Pick the template

| New host                 | Copy from                                                                                         |
| ------------------------ | ------------------------------------------------------------------------------------------------- |
| Desktop workstation      | `hosts/idols-ai/` + `outputs/x86_64-linux/src/idols-ai.nix`                                       |
| Homelab server / VM host | `hosts/12kingdoms-shoryu/` + `outputs/x86_64-linux/src/12kingdoms-shoryu.nix`                     |
| Apple Silicon Linux      | `hosts/12kingdoms-shoukei/` + `outputs/aarch64-linux/src/12kingdoms-shoukei.nix`                  |
| macOS                    | `hosts/darwin-fern/` + `outputs/aarch64-darwin/src/fern.nix` (`darwinConfigurations`, no Colmena) |
| MicroVM guest            | `hosts/k8s/k3s-test-1-worker-1/` + `outputs/x86_64-linux/src/k3s-test-1-worker-1.nix`             |

A MicroVM guest is also registered in its VM host's `microvm.nix`, and is deployed with
`just microvm-deploy`, not Colmena.

## 2. Files to create or edit

1. `hosts/<dir>/default.nix` - sets `hostName` and imports the host's modules. Some hosts (`shoryu`,
   `shushou`, `youko`, `akane`) import `mylib.scanPaths ./.`, which pulls in **every other `.nix`
   file in the directory**; keep scratch files out of those.
2. `hosts/<dir>/hardware-configuration.nix` - generated on the target machine
   (`nixos-generate-config --show-hardware-config`), never copied from another host. Where the
   layout is declarative, add `disko-fs.nix` and record the install command in the host's
   `README.md`, as `hosts/idols-ai/README.md` does.
3. `home/hosts/linux/<name>.nix` or `home/hosts/darwin/<name>.nix` - only for a host with Home
   Manager; otherwise leave `home-modules` out.
4. `outputs/<system>/src/<name>.nix` - `nixosConfigurations.<name>` (or `darwinConfigurations`),
   `colmena.<name>` with `tags`, `ssh-user = "root"`, and `targetHost`, and `packages.<name>` for an
   install ISO. Keep the leading comment about unused `args`: haumea passes them lazily and they are
   still required.
5. `vars/networking.nix` - `hostsAddr.<name> = { iface; ipv4; }` for a LAN host. That entry drives
   the static address, the SSH `Host` alias used for remote builds, and `known_hosts`, so a wrong
   `iface` takes the host offline at activation. Skip it for a DHCP or mobile host.
6. `hosts/README.md` - add the host to the inventory.

Pin service user and group ids (`service-user-ids.nix`, as on `shoryu`) before the host has state on
disk. A dynamically allocated id that moves on a later rebuild orphans the files it owned
(`9187e4d9 fix(youko): pin dynamically-allocated service uid/gid (#320)`).

## 3. Tests that fail until the host is wired

[outputs/README.md](../../../outputs/README.md#which-tests-cover-a-new-host) lists which eval tests
check every configuration and which list hosts by name. In short:

- `hostname`: a new `-niri` configuration needs a `specialExpected` entry, in the test for its
  platform (`ai-niri` in x86_64-linux, `shoukei-niri` in aarch64-linux).
- `security-*`, `kernel`, `nix-system-features`: apply to every configuration automatically.
- `home-manager`, `btrbk`, and the other host-listing tests: add the host if it should be covered.

`just test` must print `true`; an exit code of `0` with `false` is a failure.

## 4. Install and deploy

- First install: boot the ISO, partition with disko, install, then deploy normally. Follow
  [nixos-installer/README.md](../../../nixos-installer/README.md) and the host's own README.
- Remote hosts: `just col <tag>` or the host's own recipe, once its key is a secrets recipient.
- The machine you are on: `just local` or `just niri`, which prompt for `sudo`, so the user runs
  them.

## 5. Verify

- `ssh <name> true`, then `systemctl --failed` and `journalctl -b -p err` on the host.
- Secrets decrypted, checked by mode and owner only.
- The role works: the service, VM, or desktop the host exists for.
