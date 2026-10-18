# Host - Aquamarine

Headless AI inference server. Revives the `aquamarine` name, retired on 2026-09-21 when the VM of
that name was decommissioned; this is a different, physical machine that reuses the name and the
`192.168.5.101` address.

## Hardware

| Part   | Model                                                 | Notes                                                   |
| ------ | ----------------------------------------------------- | ------------------------------------------------------- |
| Board  | Colorful CVN Z890 ARK FROZEN V20 (BIOS 1013)          | moved from `ai` on 2026-10-13, so its EFI vars come too |
| CPU    | Intel Core Ultra 7 270K Plus                          | Arrow Lake; the NPU serves `whisper-asr` (./asr.nix)    |
| Memory | 2x48G JUHOR (96G), 4800 MT/s                          | the 2x16G kit stayed with `ai`                          |
| GPU    | 2x AMD Radeon AI PRO R9700, 32G each (RDNA4, gfx1201) | 64G of VRAM total                                       |
| Root   | Fanxiang S790 2TB                                     | was `ai`'s `/data` disk until 2026-10-13                |
| NIC    | Realtek RTL8125BG 2.5GbE, `enp133s0` today            | matched by the `en*` prefix                             |

Two things about this board set the ceiling for the GPU work:

- The second full-length x16 slot is chipset-attached: its root port negotiates Gen4 x4, while the
  card side reports Gen5 x16 either way (./ROCM.md has the link measurements). The chipset card
  probes **7.1 GB/s** host->device against 46.3 GB/s for the CPU-attached card, so a two-card layer
  split is 8-27% slower per request and ~9% ahead on six concurrent requests. Read the inference
  engine's `PCIe probe` line rather than `lspci`, and prefer a CPU-attached slot for a second card.
- Multi-GPU work should split by layer (RPC / pipeline parallel), not by tensor parallelism: the
  R9700 has no xGMI link between cards, and a dual-R9700 report has RCCL deadlocking with vLLM TP=2
  even with `NCCL_P2P_DISABLE=1`. See [ROCM.md](./ROCM.md).

The iGPU carries display and video work: the kernel binds `i915`, and
[hardware-intel-igpu.nix](./hardware-intel-igpu.nix) installs `intel-media-driver` (VA-API),
`vpl-gpu-rt` (oneVPL/QSV) and `intel-compute-runtime` (OpenCL/Level-Zero), so transcoding can use
its media engine while the R9700s stay on inference. VA-API targets `/dev/dri/renderD128`; OpenVINO
jobs go through `openvino-gpu <command>`, which pins the OpenCL loader the GPU plugin needs
(WA-038). A monitor plugged into the board's HDMI/DP ports still gets the text console
(`multi-user.target`, no display manager) when SSH is unreachable.

`iommu=pt` is set in [hardware-amd-gpu.nix](./hardware-amd-gpu.nix) because ROCm documents hangs on
multi-GPU systems without IOMMU passthrough. The same file disables amdgpu runtime power management:
this board's DSDT advertises ATPX power control that its own ACPI methods cannot deliver, so the
first idle resume of the headless R9700 kills it until reboot. [ROCM.md](./ROCM.md) records whose
defect that is, the supported ROCm versions, and the inference notes.

## Disk layout

Declarative via [disko-fs.nix](./disko-fs.nix): ESP + LUKS (`aqua-luks`) + btrfs subvolumes (`@nix`,
`@persistent`, `@snapshots`, `@tmp`, `@swap` with a 32G swapfile), ephemeral tmpfs root, state under
`/persistent` via [preservation.nix](./preservation.nix). Secure Boot via lanzaboote
([secureboot.nix](./secureboot.nix)).

The mapper is `aqua-luks`, not `nixos-luks`: the disk is formatted while the staging host is
running, and that host already owns the `nixos-luks` name.

## Install (staged from a running host)

This disk is installed into a machine that is not the one it gets formatted on: `disko` runs while
the disk is still attached to a running NixOS host (`ai` below), and the disk then moves to its own
machine. The target machine is the board the install runs on, so the EFI boot entry and the Secure
Boot key enrollment the host already has carry over. That is what makes a staged install possible;
it also means these steps run on a machine whose own root disk is one `disko destroy` away.

Steps 1 to 6 only touch this disk and leave `ai` running. `ai`'s own deploy and shutdown are step 7,
and they belong together: the machine comes back on the new board with this disk gone.

1. Confirm the target disk and release it: `lsblk -f` must show no mount and no open mapper on it. A
   disk reused from another role still carries that role's mounts:

   ```bash
   ls -l /dev/disk/by-id/nvme-Fanxiang_S790_2TB_FXS790254050582
   lsblk -f
   sudo umount /data                 # the previous role's mountpoint
   sudo cryptsetup close data-luks   # and its mapper
   ```

2. Partition, encrypt and mount. This **destroys everything on that disk** — re-read the `device`
   line in [disko-fs.nix](./disko-fs.nix) first. Run it as **root**: unprivileged, disko still walks
   through the confirmation prompt and then fails on every step with `Permission denied`.

   ```bash
   cd ~/nix-config
   sudo nix run github:nix-community/disko -- --mode destroy,format,mount hosts/idols-aquamarine/disko-fs.nix
   ```

   Success looks like two new partitions — `disk-nixos-aquamarine-ESP` (vfat, 600M) and
   `disk-nixos-aquamarine-root` (crypto_LUKS) — and seven mounts under `/mnt`. Check before moving
   on:

   ```bash
   lsblk -o NAME,SIZE,FSTYPE,PARTLABEL /dev/nvme0n1
   findmnt -R /mnt
   ```

3. Reuse the staging host's Secure Boot PKI bundle, so lanzaboote signs this system with a key the
   firmware already trusts. The bundle contains a private signing key: copy it yourself, and never
   commit it or send it through chat.

   ```bash
   sudo mkdir -p /mnt/persistent/etc/secureboot
   sudo cp -a /persistent/etc/secureboot/. /mnt/persistent/etc/secureboot/

   # lanzaboote reads the key from /etc/secureboot inside the target, and preservation
   # only bind-mounts that directory at boot — so expose it during the install too.
   sudo mkdir -p /mnt/etc/secureboot
   sudo mount --bind /mnt/persistent/etc/secureboot /mnt/etc/secureboot
   ```

   `nixos-install` installs the boot loader through `nixos-enter --root /mnt` and
   `NIXOS_INSTALL_BOOTLOADER=1 ... switch-to-configuration boot`, so lanzaboote's install hook reads
   `/etc/secureboot/keys/db/db.key` **from the target root**. Without the bind mount that path is an
   empty directory and the install fails at "installing the boot loader", however good the copy in
   `/mnt/persistent` is.

   Skipping this is fine only if you would rather start over: delete the firmware keys,
   `sbctl create-keys` + `sbctl enroll-keys` in setup mode. The fresh keys must end up in
   `/etc/secureboot` — lanzaboote's `pkiBundle`, while `sbctl create-keys` writes to its own keydir
   — or the firmware trusts a key this system's UKI was not signed with. That changes PCR7, so any
   TPM2 LUKS enrollment made before it stops unlocking.

4. Enroll the new LUKS volume with this board's TPM2, keeping the passphrase slot as the fallback:

   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 \
     /dev/disk/by-id/nvme-Fanxiang_S790_2TB_FXS790254050582-part2
   sudo systemd-cryptenroll /dev/disk/by-id/nvme-Fanxiang_S790_2TB_FXS790254050582-part2  # slots: expect tpm2 + passphrase
   ```

   PCR7 measures the Secure Boot key database, so enroll **after** step 3, not before. Re-run this
   whenever the Secure Boot keys change.

5. Install the real system. The closure is mostly cached on the staging host, and step 3's bind
   mount is what lets lanzaboote sign into this disk's ESP:

   ```bash
   cd ~/nix-config
   sudo nixos-install --root /mnt --flake .#aquamarine --no-root-password
   ```

   If a private flake input is not in the host's store yet, fetch it as root: `sudo` does not pass
   `SSH_AUTH_SOCK` through on this host, so run the install from a root shell with its own agent
   (`sudo su`, then `eval "$(ssh-agent)" && ssh-add ~/.ssh/<github-key>`).

   The installer writes an EFI boot entry into **this board's NVRAM** and may put it first. Do not
   reboot the staging host with both disks attached — it would boot aquamarine's system.

   The install generates the target's `/etc`, but preservation only bind-mounts `/persistent` at
   boot, so the state it looks for has to be in place before the disk is unmounted. Move the
   generated `/etc/ssh` and `machine-id` in, then read the listing:

   ```bash
   sudo nixos-enter --root /mnt
   mkdir -p /persistent/etc
   mv /etc/ssh /persistent/etc/
   mv /etc/machine-id /persistent/etc/
   ls -l /persistent/etc/ssh /persistent/etc/ssh/authorized_keys.d
   exit
   ```

   `authorized_keys.d/<user>` must be a **regular file** with mode `0444`: sshd's `StrictModes`
   rejects a key file whose path crosses `/nix/store`, which is group-writable (`1775`), so a
   symlink to `/etc/static/...` there locks every login out. `sshd_config` is a symlink to
   `/etc/static/ssh/sshd_config` on purpose — that one tracks the current generation. If a file is
   missing, copy the real one in and create its directory if needed:
   `cp -L /etc/static/ssh/authorized_keys.d/. /persistent/etc/ssh/authorized_keys.d/`.

6. Unmount the target: `umount -R /mnt` also drops step 3's bind mount. This disk is done; leave the
   staging host running for step 7.

   ```bash
   sudo umount -R /mnt
   findmnt -R /mnt          # nothing left mounted
   ```

7. On `ai`, stage its next generation **and** shut it down — one step, never one without the other.
   The machine boots on the new board with this disk gone, so the generation it comes back on must
   not wait for a LUKS volume here; and staging only takes effect at that boot, so shutting down
   first would leave the current generation as the default.

   ```bash
   # the host's initrd must no longer list this disk's mapper
   nix eval --json .#nixosConfigurations.ai-niri.config.boot.initrd.luks.devices --apply builtins.attrNames
   # [ "nixos-luks" ]

   just niri boot      # stage only: `switch` would apply the NIC rename now and cut the LAN
   sudo poweroff       # only after the deploy succeeded
   ```

   Then move the disk to its machine, in the same M.2 slot: the EFI entry names the disk by its
   device path, and a different slot can invalidate it.

## First boot on aquamarine

1. The initrd should unlock `aqua-luks` from the TPM; if it prompts, use the passphrase.
2. If the firmware has no boot entry for the disk, pick it once from the boot menu (the ESP also
   carries the `\EFI\BOOT\BOOTX64.EFI` fallback), then let the first activation write the entry.
3. From another host:

   ```bash
   ssh aquamarine ip addr
   ssh aquamarine systemctl --failed
   ssh aquamarine journalctl -b -p err
   ssh aquamarine rocminfo
   ssh aquamarine rocm-smi --showproductname
   ```

   If `ssh` refuses the connection, or `sshd` logs `bad ownership or mode for directory /nix/store`,
   the `/etc/ssh` copy under `/persistent` is incomplete — repeat step 5's check from the console
   before deploying anything else.

   `ip addr` must show `192.168.5.101` on the wired interface. The networkd match uses the `en*`
   prefix, so a renamed NIC cannot strand the host; if the address is missing, check the cable and
   `ip -br link` first.

## After the first boot

The install created a fresh SSH host key; the old `aquamarine` VM key is dead and the new one is
already in `vars/networking.nix` under `knownHosts` (2026-10-13). Redo these steps only after a
reinstall or a key rotation:

1. `ssh aquamarine cat /etc/ssh/ssh_host_ed25519_key.pub`.
2. Put that key in `vars/networking.nix` under `knownHosts` (the entry was removed with the old key)
   and, if this host should read agenix secrets, in `~/codes/nix-secrets/secrets.nix` under
   `application_server_keys`.
3. Rekey and bump the pin: `just -f secrets/Justfile rekey`, push `nix-secrets`, then
   `just upp mysecrets` here.

This config enables no `modules.secrets.*` group, so aquamarine decrypts nothing today; adding a
group is what requires the recipient step above.

## Remote builds

Aquamarine is the fleet's remote Nix builder: 24C/96G, plus `boot.binfmt.emulatedSystems` for
`aarch64-linux` and `riscv64-linux`, so one machine serves all three platforms. Clients opt in with
`modules.remote-builders.enable`, defined in `modules/nixos/base/remote-builders.nix`.

The builder's login user is `root`, which the daemon trusts by default, so this host needs no
`nix.settings.trusted-users` entry of its own. Each client's daemon authenticates with its own SSH
host key, which is passphrase-free and root-readable; `hosts/idols-aquamarine/default.nix`
authorizes those keys for root.

## Deploy

```bash
just aquamarine          # colmena, from any other host
just local               # on aquamarine itself
```

## Rollback

The install only touches the target disk; the staging host keeps booting from its own. To undo, move
the disk back, restore the `hosts/idols-ai/disko-fs-data.nix` module this change deleted, and
re-enroll that machine's TPM2 slot — see `../idols-ai/README.md`.
