# Rakushun - Orange Pi 5 Plus

LUKS encrypted SSD for NixOS, on Orange Pi 5 Plus.

## Showcases

![](../../_img/2024-03-07_orangepi5plus_rakushun.webp)

Disk layout:

```bash
[ryan@rakushun:~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda           8:0    1 58.6G  0 disk
└─sda1        8:1    1  487M  0 part
mtdblock0    31:0    0   16M  0 disk
zram0       254:0    0    0B  0 disk
nvme0n1     259:0    0  1.8T  0 disk
├─nvme0n1p1 259:1    0  630M  0 part  /boot
└─nvme0n1p2 259:2    0  1.8T  0 part
  └─crypted 253:0    0  1.8T  0 crypt /tmp
                                      /swap
                                      /snapshots
                                      /home
                                      /nix/store
                                      /var/lib
                                      /nix
                                      /
```

CPU info:

```bash
[ryan@rakushun:~]$ lscpu
Architecture:           aarch64
  CPU op-mode(s):       32-bit, 64-bit
  Byte Order:           Little Endian
CPU(s):                 8
  On-line CPU(s) list:  0-7
Vendor ID:              ARM
  Model name:           Cortex-A55
    Model:              0
    Thread(s) per core: 1
    Core(s) per socket: 4
    Socket(s):          1
    Stepping:           r2p0
    CPU(s) scaling MHz: 67%
    CPU max MHz:        1800.0000
    CPU min MHz:        408.0000
    BogoMIPS:           48.00
    Flags:              fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm lrcpc dcpop asimddp
  Model name:           Cortex-A76
    Model:              0
    Thread(s) per core: 1
    Core(s) per socket: 2
    Socket(s):          2
    Stepping:           r4p0
    CPU(s) scaling MHz: 18%
    CPU max MHz:        2256.0000
    CPU min MHz:        408.0000
    BogoMIPS:           48.00
    Flags:              fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm lrcpc dcpop asimddp
Caches (sum of all):
  L1d:                  384 KiB (8 instances)
  L1i:                  384 KiB (8 instances)
  L2:                   2.5 MiB (8 instances)
  L3:                   3 MiB (1 instance)
```

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


