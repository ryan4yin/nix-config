# Rakushun - Orange Pi 5 Plus

LUKS encrypted SSD for NixOS, on Orange Pi 5 Plus.

## How to install NixOS on Orange Pi 5 Plus

### 1. Prepare a USB LUKS key

Generate LUKS keyfile to encrypt the root partition, it's used by disko.

```bash
# partition the usb stick
DEV=/dev/sdX
parted ${DEV} -- mklabel gpt
parted ${DEV} -- mkpart OPI5P_DSC fat32 0% 512MB
mkfs.fat -F 32 -n OPI5P_DSC ${DEV}1

# Generate a keyfile from the true random number generator
KEYFILE=./orangepi5plus-luks-keyfile
dd bs=512 count=64 iflag=fullblock if=/dev/random of=$KEYFILE

# copy the keyfile and token to the usb stick
KEYFILE=./orangepi5plus-luks-keyfile
DEVICE=/dev/disk/by-label/OPI5P_DSC
# seek=128 skip N obs-sized output blocks to avoid overwriting the filesystem header
dd bs=512 count=64 iflag=fullblock seek=128 if=$KEYFILE of=$DEVICE
```

### 2. Partition the SSD & install NixOS via disko

First, follow [UEFI - ryan4yin/nixos-rk3588](https://github.com/ryan4yin/nixos-rk3588/blob/main/UEFI.md) to install UEFI bootloader and boot into NixOS live environment via a USB stick.

Then, run the following commands:

```bash
# transfer the nix-config to the target machine
rsync -avzP ~/nix-config rk@<ip-addr>:/home/rk/

# login via ssh
ssh rk@<ip-addr>

cd ~/nix-config/hosts/12kingdoms_rakushun
# 1. change the disk device path in ./disko-fs.nix to the disk you want to use
# 2. partition & format the disk via disko
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko-fs.nix


cd ~/nix-config
# install nixos
# NOTE: the root password you set here will be discarded when reboot
sudo nixos-install --root /mnt --flake .#rakushun --no-root-password --show-trace --verbose
```


