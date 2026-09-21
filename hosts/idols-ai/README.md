# Host - AI

Desktop (NixOS + preservation, LUKS + btrfs on nvme). Disk layout is declarative via
[disko](./disko-fs.nix) (target device: **nvme1n1**).

Related:

- [nixos-installer README](../nixos-installer/README.md) – install from ISO using disko
- [disko-fs.nix](./disko-fs.nix) – main disk layout (ESP + LUKS + btrfs). From
  `nix-config/nixos-installer`:  
  `nix run github:nix-community/disko -- --mode destroy,format,mount ../hosts/idols-ai/disko-fs.nix`
- [disko-fs-data.nix](./disko-fs-data.nix) – data disk layout (LUKS + btrfs at /persistent/data)

## TODOs

1. Install DCGM-Exporter on `ai` to monitor the GPU status.

## Info

The disk layout is fully declarative — see [disko-fs.nix](./disko-fs.nix) for the root disk and
[disko-fs-data.nix](./disko-fs-data.nix) for the data disk. Run `df -Th` / `lsblk` on the host if an
up-to-date snapshot of the current mounts is needed.
