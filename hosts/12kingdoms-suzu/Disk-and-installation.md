# Suzu - Disk and Installation

Disk layout:

```bash
[ryan@suzu:~]$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
sda           8:0    1  58.6G  0 disk
└─sda1        8:1    1   486M  0 part
mtdblock0    31:0    0    16M  0 disk
zram0       254:0    0     0B  0 disk
nvme0n1     259:0    0 238.5G  0 disk
├─nvme0n1p1 259:1    0   630M  0 part  /boot
└─nvme0n1p2 259:2    0 237.9G  0 part
  └─encrypted 253:0    0 237.8G  0 crypt /tmp
                                       /snapshots
                                       /swap
                                       /home/ryan/tmp
                                       /home/ryan/nix-config
                                       /home/ryan/go
                                       /home/ryan/.local/state
                                       /home/ryan/codes
                                       /home/ryan/.npm
                                       /home/ryan/.ssh
                                       /home/ryan/.local/share
                                       /etc/ssh
                                       /home/ryan/.conda
                                       /etc/secureboot
                                       /etc/agenix
                                       /etc/nix/inputs
                                       /etc/NetworkManager/system-connections
                                       /nix/store
                                       /var/log
                                       /var/lib
                                       /nix
                                       /persistent

[ryan@suzu:~]$ df -Th
Filesystem          Type      Size  Used Avail Use% Mounted on
devtmpfs            devtmpfs  383M     0  383M   0% /dev
tmpfs               tmpfs     3.8G     0  3.8G   0% /dev/shm
tmpfs               tmpfs     1.9G  6.2M  1.9G   1% /run
tmpfs               tmpfs     3.8G  1.9M  3.8G   1% /run/wrappers
none                tmpfs     2.0G   48K  2.0G   1% /
/dev/mapper/crypted btrfs     238G   11G  226G   5% /persistent
/dev/mapper/crypted btrfs     238G   11G  226G   5% /nix
/dev/mapper/crypted btrfs     238G   11G  226G   5% /swap
/dev/mapper/crypted btrfs     238G   11G  226G   5% /snapshots
/dev/mapper/crypted btrfs     238G   11G  226G   5% /tmp
/dev/nvme0n1p1      vfat      629M   86M  543M  14% /boot
tmpfs               tmpfs     766M  4.0K  766M   1% /run/user/1000
```

CPU info:

```bash
[ryan@suzu:~]$ lscpu
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
    CPU(s) scaling MHz: 56%
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

## How to install NixOS on Orange Pi 5

### 1. Prepare a USB LUKS key

Generate LUKS keyfile to encrypt the root partition, it's used by disko.

```bash
# partition the usb stick
DEV=/dev/sdX
parted ${DEV} -- mklabel gpt
parted ${DEV} -- mkpart primary 2M 512MB
mkfs.fat -F 32 -n OPI5_DSC ${DEV}1


# Generate a keyfile from the true random number generator
KEYFILE=./orangepi5-luks-keyfile
dd bs=512 count=64 iflag=fullblock if=/dev/random of=$KEYFILE

# copy the keyfile and token to the usb stick
KEYFILE=./orangepi5-luks-keyfile
DEVICE=/dev/disk/by-label/OPI5_DSC
# seek=128 skip N obs-sized output blocks to avoid overwriting the filesystem header
dd bs=512 count=64 iflag=fullblock seek=128 if=$KEYFILE of=$DEVICE
```

### 2. Partition the SSD & install NixOS via disko

First, follow
[UEFI - ryan4yin/nixos-rk3588](https://github.com/ryan4yin/nixos-rk3588/blob/main/UEFI.md) to
install UEFI bootloader and boot into NixOS live environment via a USB stick.

Then, run the following commands:

```bash
# login via ssh
ssh rk@<ip-addr>

git clone https://github.com/ryan4yin/nix-config.git

cd ~/nix-config/hosts/12kingdoms_suzu
# 1. change the disk device path in ./disko-fs.nix to the disk you want to use
# 2. partition & format the disk via disko
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko-fs.nix


cd ~/nix-config
# install nixos
sudo nixos-install --root /mnt --flake .#suzu --no-root-password --show-trace --verbose

# enter into the installed system, check password & users
# `su ryan` => `sudo -i` => enter ryan's password => successfully login
# if login failed, check the password you set in install-1, and try again
nixos-enter

# NOTE: DO NOT skip this step!!!
# copy the essential files into /persistent
# otherwise the / will be cleared and data will lost
## NOTE: impermanence just create links from / to /persistent
##       We need to copy files into /persistent manually!!!
mv /etc/machine-id /persistent/etc/
mv /etc/ssh /persistent/etc/
mkdir -p /persistent/home/ryan
chown -R ryan:ryan /persistent/home/ryan
```
