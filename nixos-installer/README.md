# Nix Environment Setup for Host: Idols - Ai

> :red_circle: **IMPORTANT**: **Do not deploy this flake directly on your machine.** Write your own
> configuration from scratch and use this only as reference.\*\*

This flake prepares a Nix environment for setting up the desktop host
[hosts/idols-ai](../hosts/idols-ai/) (from the main flake) on a new machine.

Other docs:

- [README for 12kingdoms-shoukei](./README.shoukei.md)

## Why this flake exists

The main flake is heavy and slow to deploy. This minimal flake helps to:

1. Adjust and verify `hardware-configuration.nix` and disk layout before deploying the main flake.
2. Test preservation, Secure Boot, TPM2, encryption, etc. on a VM or fresh install.

Disk layout is **declarative** via [disko](https://github.com/nix-community/disko); manual
partitioning is no longer needed.

## Steps to deploy

1. Create a USB install medium from the official NixOS ISO and boot from it.

### 1. Partition and mount with disko (recommended)

Layout is defined in [../hosts/idols-ai/disko-fs.nix](../hosts/idols-ai/disko-fs.nix): **nvme1n1**,
ESP (450M) + LUKS + btrfs (subvolumes: @nix, @guix, @persistent, @snapshots, @tmp, @swap). Root is
tmpfs; [preservation](https://github.com/nix-community/preservation) uses `/persistent`.

```bash
git clone https://github.com/ryan4yin/nix-config.git
cd nix-config/nixos-installer

sudo su

# encrypt the root partition with luks2 and argon2id, will prompt for a passphrase, which will be used to unlock the partition.
# WARNING: destroys all data on nvme1n1. Layout is mounted at /mnt by default.
nix run github:nix-community/disko -- --mode destroy,format,mount ../hosts/idols-ai/disko-fs.nix

# Mount only (e.g. after first format, without wiping):
# nix run github:nix-community/disko -- --mode mount ../hosts/idols-ai/disko-fs.nix

# setup the automatic unlock via the tpm2 chip
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/<encrypted-disk-part-path>
```

### 2. Install NixOS

```bash
sudo su

# add ssh key to ssh-agent, it's required to pull my asahi=firmware
$(ssh-agent)
ssh-add /path/to/ssh-key

# From nix-config/nixos-installer
nixos-install --root /mnt --flake .#ai --no-root-password
```

### 3. Copy data into /persistent and reboot

Preservation expects state under `/persistent`; copy or migrate data there (e.g. from an old disk),
then leave the chroot and reboot.

```bash
nixos-enter

# Copy/migrate into /persistent as needed (e.g. from old nvme0n1)
# At minimum for a fresh install:
#   mkdir -p /persistent/etc
#   mv /etc/machine-id /persistent/etc/
#   mv /etc/ssh /persistent/etc/
# Then exit and:
exit
umount -R /mnt
reboot
```

After reboot, set the boot order in firmware so the system boots from nvme1n1. The old disk (e.g.
nvme0n1) can be reused for something else.

### Optional: use a cache mirror

```bash
nixos-install --root /mnt --flake .#ai --no-root-password \
  --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/"
```

## Deploying the main flake after install

After the first boot:

1. **SSH key** (for pulling the private secrets repo):

   ```bash
   ssh-keygen -t ed25519 -a 256 -C "ryan@idols-ai" -f ~/.ssh/idols_ai
   ssh-add ~/.ssh/idols_ai
   ```

2. Rekey secrets for the new host: follow [../secrets/README.md](../secrets/README.md) so agenix can
   decrypt using this host’s SSH key.

3. Deploy the main config:

   ```bash
   sudo mv /etc/nixos ~/nix-config
   sudo chown -R ryan:ryan ~/nix-config
   cd ~/nix-config
   just hypr
   ```

4. **Secure Boot**: follow
   [lanzaboote Quick Start](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
   and [hosts/idols-ai/secureboot.nix](../hosts/idols-ai/secureboot.nix).

## Changing LUKS2 passphrase

```bash
# Test current passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/device

# Change passphrase
sudo cryptsetup luksChangeKey /path/to/device

# Verify
sudo cryptsetup --verbose open --test-passphrase /path/to/device
```

## Reference: layout and manual partitioning

The layout (ESP + LUKS + btrfs, ephemeral root, preservation on `/persistent`) is described in
[../hosts/idols-ai/disko-fs.nix](../hosts/idols-ai/disko-fs.nix). Prefer using disko; manual
partitioning is no longer documented here.

Background:

- [NixOS manual installation](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning)
- [dm-crypt / Encrypting an entire system (Arch)](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)
- [cryptsetup FAQ](https://gitlab.com/cryptsetup/cryptsetup/wikis/FrequentlyAskedQuestions)
