# Host - AI

Desktop (NixOS + preservation, LUKS + btrfs on nvme). Disk layout is declarative via
[disko](./disko-fs.nix) (target device: the KINGBANK NVMe by `/dev/disk/by-id/`, set in that file).

Desktop on the MSI **MAG B760M MORTAR** with the i5-13600KF, 32G DDR5 and the RTX 4090, on the
KINGBANK NVMe alone. The platform split is recorded in [hosts/README.md](../README.md); the wired
NIC and its `en*` match are in [default.nix](./default.nix).

TPM2 comes from the CPU's Intel PTT unless a module is plugged into the board's TPM header; check
_Settings → Security → Trusted Computing_ if `systemd-cryptenroll --tpm2-device=auto` finds no
device.

Related:

- [nixos-installer README](../../nixos-installer/README.md) – install from ISO using disko
- [disko-fs.nix](./disko-fs.nix) – main disk layout (ESP + LUKS + btrfs). From
  `nix-config/nixos-installer`:  
  `nix run github:nix-community/disko -- --mode destroy,format,mount ../hosts/idols-ai/disko-fs.nix`
- [VR.md](./VR.md) – WiVRn headset setup

## Info

The disk layout is fully declarative — see [disko-fs.nix](./disko-fs.nix) for the root disk. Run
`df -Th` / `lsblk` on the host if an up-to-date snapshot of the current mounts is needed.

Steam libraries live under the persisted home directory, so they survive the tmpfs root:
`~/Games/SteamLibrary` is the library that used to sit on the `/data` disk. Steam finds a moved
library when it is added once through _Settings → Storage → Add Drive_, or by starting Steam with
the `libraryfolders.vdf` already listing it.

## 4090 water block

After the 2026-10-13 platform swap the card's water block stopped moving heat: the pump ran but made
abnormal noise, and the card still overheated. It had been RMA'd for the same symptom before, came
back with no fault found, and worked again after the return shipment. Repacking the card in its
original box and dropping the box five or six times freed it, so a stuck impeller, with transit
shock as the accidental cure, is the best guess. Treat that as a stopgap before an RMA: the jolt can
damage the card, and a pump that sticks again should be replaced.

## Booting after the platform swap

The KINGBANK disk was last enrolled with the Z890 board's TPM2 and its UKI is signed with a key that
only that board's Secure Boot database trusts. On the B760M board:

1. Boot with the LUKS **passphrase** — the old TPM2 enrollment is bound to the previous board's PCR
   values and will not unlock here.
2. Secure Boot: either leave it off, or enroll a fresh PKI — `sbctl create-keys` +
   `sbctl enroll-keys` in setup mode. lanzaboote signs with `pkiBundle` (`/etc/secureboot` in
   [secureboot.nix](./secureboot.nix)), so the new keys must end up there; `sbctl create-keys`
   writes to its own keydir. Re-enrolling changes PCR7, so re-run the enrollment in step 3
   afterwards.
3. Re-enroll this board's TPM2 once the Secure Boot state is final. Enroll and wipe in **one** call:
   `--wipe-slot=tpm2` matches every TPM2 slot, so wiping in a separate call would also delete the
   slot just created. Combined, systemd-cryptenroll enrolls first and then wipes the old slots,
   always sparing the new one.

   ```bash
   disk=/dev/disk/by-id/nvme-KINGBANK_KP260_CN092BH3203917-part2
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 --wipe-slot=tpm2 "$disk"
   sudo systemd-cryptenroll "$disk"   # read the slot list back: tpm2 + passphrase
   ```

   PCR0 covers the firmware code, so a BIOS update needs this enrollment redone; the passphrase slot
   keeps booting either way. The `0+7` pair is the repo's existing shape — see
   [nixos-installer/README.md](../../nixos-installer/README.md).

4. The B760M's NVRAM has no boot entry for this disk. If it does not boot on its own, pick the disk
   once from the one-time boot menu (the ESP also carries `\EFI\BOOT\BOOTX64.EFI`); the first
   activation should then write the entry. If it does not, add one by hand — `ls /boot/EFI/Linux`
   shows the UKI name lanzaboote signed:

   ```bash
   sudo ls /boot/EFI/Linux
   sudo nix run nixpkgs#efibootmgr -- -c -d /dev/disk/by-id/nvme-KINGBANK_KP260_CN092BH3203917 \
     -p 1 -L NixOS -l '\EFI\Linux\nixos-generation-1.efi'
   ```
