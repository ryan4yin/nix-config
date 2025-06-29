# Nix Environment Setup for Host: Idols - Ai

> :red_circle: **IMPORTANT**: **Once again, you should NOT deploy this flake directly on your
> machine :exclamation: Please write your own configuration from scratch, and use my configuration
> and documentation for reference only.**

This flake prepares a Nix environment for setting my desktop [/hosts/idols_ai](/hosts/idols_ai/)(in
main flake) up on a new machine.

Other docs:

- README for [/hosts/12kingdoms_shoukei](/hosts/12kingdoms_shoukei):
  [./README.shoukei.md](./README.shoukei.md)

TODOs:

- [ ] declarative disk partitioning with [disko](https://github.com/nix-community/disko)

## Why an extra flake is needed?

The configuration of the main flake, [/flake.nix](/flake.nix), is heavy, and it takes time to debug
& deploy. This simplified flake is tiny and can be deployed very quickly, it helps me to:

1. Adjust & verify my `hardware-configuration.nix` modification quickly before deploying the main
   flake.
2. Test some new filesystem related features on a NixOS virtual machine, such as preservation,
   Secure Boot, TPM2, Encryption, etc.

## Steps to Deploying this flake

First, create a USB install medium from NixOS's official ISO image and boot from it.

### 1. Encrypting with LUKS(everything except ESP)

> https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning

> [dm-crypt/Encrypting an entire system - Arch Wiki](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)

> [Encrypted /boot - GRUB2 - Arch Wiki](https://wiki.archlinux.org/title/GRUB#Encrypted_/boot)

> [Frequently asked questions (FAQ) - cryptsetup](https://gitlab.com/cryptsetup/cryptsetup/wikis/FrequentlyAskedQuestions)

Securing a root file system is where dm-crypt excels, feature and performance-wise. An encrypted
root file system protects everything on the system, it make the system a black box to the attacker.

1. The EFI system partition(ESP) must be left unencrypted, and is mounted at `/boot`
   1. Since the UEFI firmware can only load boot loaders from unencrypted partitions.
2. Secure Boot is enabled, everything in ESP is signed.
3. The BTRFS file system with subvolumes is used for the root partition, and the swap area is a
   swapfile on a dedicated BTRFS subvolume, thus the swap area is also encrypted.

And the boot flow is:

1. The UEFI firmware loads the boot loader from the ESP(`/boot`).
2. The boot loader loads the kernel and initrd from the ESP(`/boot`).
3. **The initrd prompts for the passphrase to unlock the root partition**.
4. The initrd unlocks the root partition and mounts it at `/`.
5. The initrd continues the boot process, and hands over the control to the kernel.

Partitioning the disk:

```bash
# NOTE: `cat README.md | grep part-1 > part-1.sh` to generate this script

# Create a GPT partition table
parted /dev/nvme0n1 -- mklabel gpt  # part-1

# NixOS by default uses the ESP (EFI system partition) as its /boot partition
# Create a 512MB EFI system partition
parted /dev/nvme0n1 -- mkpart ESP fat32 2MB 629MB  # part-1

# set the boot flag on the ESP partition
# Format:
#    set partition flag state
parted /dev/nvme0n1 -- set 1 esp on  # part-1

# Create the root partition using the rest of the disk
# Format:
#   mkpart [part-type name fs-type] start end
parted /dev/nvme0n1 -- mkpart primary 630MB 100%  # part-1

# show disk status
lsblk
```

Encrypting the root partition:

```bash
lsblk
# show cryptsetup's compiled in defaults
cryptsetup --help

# NOTE: `cat shoukei.md | grep luks > luks.sh` to generate this script
# encrypt the root partition with luks2 and argon2id, will prompt for a passphrase, which will be used to unlock the partition.
cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash sha512 --iter-time 5000 --key-size 256 --pbkdf argon2id --use-random --verify-passphrase /dev/nvme0n1p2

# show status
cryptsetup luksDump /dev/nvme0n1p2

# open(unlock) the device with the passphrase you just set
cryptsetup luksOpen /dev/nvme0n1p2 crypted-nixos

# show disk status
lsblk
```

Formatting the root partition:

```bash
# NOTE: `cat shoukei.md | grep create-btrfs > btrfs.sh` to generate this script
mkfs.fat -F 32 -n ESP /dev/nvme0n1p1  # create-btrfs
# format the root partition with btrfs and label it
mkfs.btrfs -L crypted-nixos /dev/mapper/crypted-nixos   # create-btrfs

# mount the root partition and create subvolumes
mount /dev/mapper/crypted-nixos /mnt  # create-btrfs
btrfs subvolume create /mnt/@nix  # create-btrfs
btrfs subvolume create /mnt/@guix  # create-btrfs
btrfs subvolume create /mnt/@tmp  # create-btrfs
btrfs subvolume create /mnt/@swap  # create-btrfs
btrfs subvolume create /mnt/@persistent  # create-btrfs
btrfs subvolume create /mnt/@snapshots  # create-btrfs
umount /mnt  # create-btrfs

# NOTE: `cat shoukei.md | grep mount-1 > mount-1.sh` to generate this script
# Remount the root partition with the subvolumes you just created
#
# Enable zstd compression to:
#   1. Reduce the read/write operations, which helps to:
#     1. Extend the life of the SSD.
#     2. improve the performance of disks with low IOPS / RW throughput, such as HDD and SATA SSD.
#   2. Save the disk space.
mkdir /mnt/{nix,gnu,tmp,swap,persistent,snapshots,boot}  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@nix /dev/mapper/crypted-nixos /mnt/nix  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@guix /dev/mapper/crypted-nixos /mnt/gnu  # mount-1
mount -o compress-force=zstd:1,subvol=@tmp /dev/mapper/crypted-nixos /mnt/tmp  # mount-1
mount -o subvol=@swap /dev/mapper/crypted-nixos /mnt/swap  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@persistent /dev/mapper/crypted-nixos /mnt/persistent  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@snapshots /dev/mapper/crypted-nixos /mnt/snapshots  # mount-1
mount /dev/nvme0n1p1 /mnt/boot  # mount-1

# create a swapfile on btrfs file system
# This command will disable CoW / compression on the swap subvolume and then create a swapfile.
# because the linux kernel requires that swapfile must not be compressed or have copy-on-write(CoW) enabled.
btrfs filesystem mkswapfile --size 96g --uuid clear /mnt/swap/swapfile  # mount-1

# check whether the swap subvolume has CoW disabled
# the output of `lsattr` for the swap subvolume should be:
#    ---------------C------ /swap/swapfile
# if not, delete the swapfile, and rerun the commands above.
lsattr /mnt/swap

# mount the swapfile as swap area
swapon /mnt/swap/swapfile  # mount-1
```

Now, the disk status should be:

```bash
# show disk status
$ lsblk
nvme0n1           259:0    0   1.8T  0 disk
├─nvme0n1p1       259:2    0   600M  0 part  /mnt/boot
└─nvme0n1p2       259:3    0   1.8T  0 part
  └─crypted-nixos 254:0    0   1.8T  0 crypt /mnt/swap
                                             /mnt/persistent
                                             /mnt/snapshots
                                             /mnt/nix
                                             /mnt/tmp

# show swap status
$ swapon -s
Filename				Type		Size		Used		Priority
/swap/swapfile                          file		100663292	0		-2
```

### 2. Generating the NixOS Configuration and Installing NixOS

Clone this repository:

```bash
# enter an shell with git/vim/ssh-agent/gnumake available
nix-shell -p git vim gnumake

# clone this repository
git clone https://github.com/ryan4yin/nix-config.git
```

Then, generate the NixOS configuration:

```bash
# nixos configurations
nixos-generate-config --root /mnt

# we need to update our filesystem configs in old hardware-configuration.nix according to the generated one.
cp /etc/nixos/hardware-configuration.nix ./nix-config/hosts/idols_ai/hardware-configuration-new.nix
vim .
```

Then, Install NixOS:

```bash
cd ~/nix-config/hosts/idols_ai/nixos-installer

# run this command if you're retrying to run nixos-install
rm -rf /mnt/etc

# install nixos
# NOTE: the root password you set here will be discarded when reboot
nixos-install --root /mnt --flake .#ai --no-root-password --show-trace --verbose # instlall-1

# if you want to use a cache mirror, run this command instead
# replace the mirror url with your own
nixos-install --root /mnt --flake .#ai --no-root-password --show-trace --verbose --option substituters "https://mirror.sjtu.edu.cn/nix-channels/store"  # install-2

# enter into the installed system, check password & users
# `su ryan` => `sudo -i` => enter ryan's password => successfully login
# if login failed, check the password you set in install-1, and try again
nixos-enter

# NOTE: DO NOT skip this step!!!
# copy the essential files into /persistent
# otherwise the / will be cleared and data will lost
## NOTE: preservation just create links from / to /persistent
##       We need to copy files into /persistent manually!!!
mv /etc/machine-id /persistent/etc/
mv /etc/ssh /persistent/etc/


# delete the generated configuration after editing
rm -f /mnt/etc/nixos
rm ~/nix-config/hosts/idols_ai/hardware-configuration-new.nix

# NOTE: `cat shoukei.md | grep git-1 > git-1.sh` to generate this script
# commit the changes after installing nixos successfully
git config --global user.email "ryan4yin@linux.com"   # git-1
git config --global user.name "Ryan Yin"              # git-1
git commit -am "feat: update hardware-configuration"

# copy our configuration to the installed file system
cp -r ../nix-config /mnt/etc/nixos

# sync the disk, unmount the partitions, and close the encrypted device
sync
swapoff /mnt/swap/swapfile
umount -R /mnt
cryptsetup close /dev/mapper/crypted-nixos
reboot
```

And then reboot.

## Deploying the main flake's NixOS configuration

After rebooting, we need to generate a new SSH key for the new machine, and add it to GitHub, so
that the new machine can pull my private secrets repo:

```bash
# 1. Generate a new SSH key with a strong passphrase
ssh-keygen -t ed25519 -a 256 -C "ryan@idols-ai" -f ~/.ssh/idols_ai
# 2. Add the ssh key to the ssh-agent, so that nixos-rebuild can use it to pull my private secrets repo.
ssh-add ~/.ssh/idols_ai
```

Then follow the instructions in [../secrets/README.md](../secrets/README.md) to rekey all my secrets
with the new host's system-level SSH key(`/etc/ssh/ssh_host_ed25519_key`), so that agenix can
decrypt them automatically on the new host when I deploy my NixOS configuration.

After all these steps, we can finally deploy the main flake's NixOS configuration by:

```bash
sudo mv /etc/nixos ~/nix-config
sudo chown -R ryan:ryan ~/nix-config

cd ~/nix-config

# deploy the configuration via Justfile
just hypr
```

Finally, to enable secure boot, follow the instructions in
[lanzaboote - Quick Start](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
and
[nix-config/ai/secure-boot.nix](https://github.com/ryan4yin/nix-config/blob/main/hosts/idols_ai/secureboot.nix)

## Change LUKS2's passphrase

```bash
# test the old passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/dev/

# change the passphrase
sudo cryptsetup luksChangeKey /path/to/dev/

# test the new passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/dev/
```
