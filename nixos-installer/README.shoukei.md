# Nix Environment Setup for Host: 12Kingdoms - Shoukei

> :red_circle: **IMPORTANT**: **Once again, you should NOT deploy this flake directly on your
> machine :exclamation: Please write your own configuration from scratch, and use my configuration
> and documentation for reference only.**

This flake prepares a Nix environment for setting my desktop
[/hosts/12kingdoms-shoukei](/hosts/12kingdoms-shoukei)(in main flake) up on a new machine.

## Steps to Deploying

### 1. Prepare & boot into the nixos installer

Just follow this Guide:

- https://github.com/nix-community/nixos-apple-silicon/blob/main/docs/uefi-standalone.md

### 2. Connect to WiFi & SSH

If you have another machine, configure the new host through a SSH connection will be much
comfortable than using the raw terminal of the nixos installer. So after booting into the nixos
installer, let's configure WiFi in the installer using `iwctl` first:

> This is copied from
> <https://github.com/nix-community/nixos-apple-silicon/blob/main/docs/uefi-standalone.md#nixos-installation>

```bash
nixos# iwctl
NetworkConfigurationEnabled: enabled
StateDirectory: /var/lib/iwd
Version: 2.4
[iwd]# station wlan0 scan
[iwd]# station wlan0 connect <SSID>
Type the network passphrase for <SSID> psk.
Passphrase: <your passphrase>
[iwd]# station wlan0 show
[...]
[iwd] exit
```

And then set a password for the `root` user:

```bash
# Switch to root
[nixos@nixos:~]$ sudo su

# Change the password
[root@nixos:~]# passwd
New password:
Retype new password:
passwd: password updated successfully

# Get the IP address
[root@nixos:~]# ip addr show wlan0
2: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 9c:3e:53:6e:ef:8d brd ff:ff:ff:ff:ff:ff
    inet 192.168.5.13/24 brd 192.168.5.255 scope global dynamic noprefixroute wlan0

# Change default router(if need)
ip route del default via 192.168.5.1
ip route add default via 192.168.5.178
```

The nixos installer has sshd service enabled by default, so we can now connect to it via ssh
directly.

### 3. Encrypting with LUKS(everything except ESP)

Disk layout before installation:

```bash
[root@nixos:~]# sudo parted /dev/nvme0n1 print free
Model: APPLE SSD AP0256Z (nvme)
Disk /dev/nvme0n1: 251GB
Sector size (logical/physical): 4096B/4096B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name                  Flags
 1      24.6kB  524MB   524MB                iBootSystemContainer
 2      524MB   66.2GB  65.7GB
 3      66.2GB  68.7GB  2500MB
 4      68.7GB  69.2GB  500MB   fat32                              boot, esp
        69.2GB  246GB   176GB   Free Space
 5      246GB   251GB   5369MB               RecoveryOSContainer
```

1. `/dev/nvme0n1p1`: "iBootSystemContainer" - system-wide boot data
2. `/dev/nvme0n1p2`: macOS's root partition.
3. `/dev/nvme0n1p4`: The EFI partition for NixOS.
4. `/dev/nvme0n1p5`: "RecoveryOSContainer" - System RecoveryOS

Now let's recreate the root partition via `sgdisk`:

```bash
# Create the root partition to fill up the free space
# --new=partnum:start:end - 0 means calculate it automatically
[root@nixos:~]# sgdisk /dev/nvme0n1 --new=0:0:0 --change-name=0:"NixOS rootfs"

The operation has completed successfully.

[root@nixos:~]# sudo parted /dev/nvme0n1 print free
Model: APPLE SSD AP0256Z (nvme)
Disk /dev/nvme0n1: 251GB
Sector size (logical/physical): 4096B/4096B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name                  Flags
 1      24.6kB  524MB   524MB                iBootSystemContainer
 2      524MB   66.2GB  65.7GB
 3      66.2GB  68.7GB  2500MB
 4      68.7GB  69.2GB  500MB   fat32                              boot, esp
 6      69.2GB  246GB   176GB                NixOS rootfs
 5      246GB   251GB   5369MB               RecoveryOSContainer
```

And then encrypting the new partition via LUKS:

```bash
lsblk
# show cryptsetup's compiled in defaults
cryptsetup --help

# NOTE: `cat shoukei.md | grep luks > format.sh` to generate this script
# encrypt the root partition with luks2 and argon2id, will prompt for a passphrase, which will be used to unlock the partition.
cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash sha512 --iter-time 5000 --key-size 256 --pbkdf argon2id --use-random --verify-passphrase /dev/nvme0n1p6

# show status
cryptsetup luksDump /dev/nvme0n1p6

# open(unlock) the device with the passphrase you just set
cryptsetup luksOpen /dev/nvme0n1p6 crypted-nixos

# show disk status
lsblk
```

Formatting the root partition:

```bash
# If btrfs is not included in the liveos, run this before formatting
nix-shell -p btrfs-progs

# NOTE: `cat shoukei.md | egrep "create-btrfs"  > create-btrfs.sh` to generate this script
# format the root partition with btrfs and label it
# set sectorsize to match the CPU page size
mkfs.btrfs --sectorsize 16384 -L crypted-nixos /dev/mapper/crypted-nixos  # create-btrfs
# mount the root partition and create subvolumes
mount /dev/mapper/crypted-nixos /mnt  # create-btrfs
btrfs subvolume create /mnt/@nix  # create-btrfs
btrfs subvolume create /mnt/@tmp  # create-btrfs
btrfs subvolume create /mnt/@swap  # create-btrfs
btrfs subvolume create /mnt/@persistent  # create-btrfs
btrfs subvolume create /mnt/@snapshots  # create-btrfs
umount /mnt  # create-btrfs

# NOTE: `cat shoukei.md | grep mount-1 > create-btrfs.sh` to generate this script
# Remount the root partition with the subvolumes you just created
#
# Enable zstd compression to:
#   1. Reduce the read/write operations, which helps to:
#     1. Extend the life of the SSD.
#     2. improve the performance of disks with low IOPS / RW throughput, such as HDD and SATA SSD.
#   2. Save the disk space.
mkdir /mnt/{nix,tmp,swap,persistent,snapshots,boot}  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@nix /dev/mapper/crypted-nixos /mnt/nix  # mount-1
mount -o compress-force=zstd:1,subvol=@tmp /dev/mapper/crypted-nixos /mnt/tmp          # mount-1
mount -o subvol=@swap /dev/mapper/crypted-nixos /mnt/swap  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@persistent /dev/mapper/crypted-nixos /mnt/persistent   # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@snapshots /dev/mapper/crypted-nixos /mnt/snapshots     # mount-1

mount /dev/nvme0n1p4 /mnt/boot  # mount-1

# create a swapfile on btrfs file system
# This command will disable CoW / compression on the swap subvolume and then create a swapfile.
# because the linux kernel requires that swapfile must not be compressed or have copy-on-write(CoW) enabled.
btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/swap/swapfile  # mount-1

# check whether the swap subvolume has CoW disabled
# the output of `lsattr` for the swap subvolume should be:
#    ---------------C------ /swap/swapfile
# if not, delete the swapfile, and rerun the commands above.
lsattr /mnt/swap

# mount the swapfile as swap area
swapon /mnt/swap/swapfile --fixpgsz  # mount-1
```

Now, the disk status should be:

```bash
# show disk status
[nix-shell:~]# lsblk
NAME              MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0               7:0    0 302.1M  1 loop  /nix/.ro-store
sda                 8:0    1     0B  0 disk
sdb                 8:16   1  58.2G  0 disk  /iso
nvme0n1           259:0    0 233.8G  0 disk
├─nvme0n1p1       259:1    0   500M  0 part
├─nvme0n1p2       259:2    0  61.2G  0 part
├─nvme0n1p3       259:3    0   2.3G  0 part
├─nvme0n1p4       259:4    0   477M  0 part  /mnt/boot
├─nvme0n1p5       259:5    0     5G  0 part
└─nvme0n1p6       259:14   0 164.3G  0 part
  └─crypted-nixos 252:0    0 164.3G  0 crypt /mnt/snapshots
                                             /mnt/persistent
                                             /mnt/swap
                                             /mnt/tmp
                                             /mnt/nix
nvme0n2           259:6    0     3M  0 disk
nvme0n3           259:7    0   128M  0 disk

# show swap status
[nix-shell:~]# swapon -s
Filename                                Type            Size            Used            Priority
/mnt/swap/swapfile                      file            16777200        0               -2
```

### 3. Generating the NixOS Configuration and Installing NixOS

Clone this repository:

```bash
# enter an shell with git/vim/ssh-agent/gnumake available
nix-shell -p git neovim --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store"

# clone this repository
git clone https://github.com/ryan4yin/nix-config.git
```

Then, generate the NixOS configuration:

```bash
# nixos configurations
nixos-generate-config --root /mnt

# we need to update our filesystem configs in old hardware-configuration.nix according to the generated one.
cp /etc/nixos/hardware-configuration.nix ./nix-config/hosts/12kingdoms_shoukei/hardware-configuration-new.nix
vim ./nix-config
```

Then, Install NixOS:

```bash
cd ~/nix-config/nixos-installer/

# run this command if you're retrying to run nixos-install
rm -rf /mnt/etc

# install nixos
# NOTE: the root password you set here will be discarded when reboot
nixos-install --root /mnt --flake .#shoukei --no-root-password --show-trace --verbose # install-1

# if you want to use a cache mirror, run this command instead
# replace the mirror url with your own
nixos-install --root /mnt --flake .#shoukei --no-root-password --show-trace --verbose --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store  https://cache.nixos.org/" # install-2

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
umount -R /mnt/{nix,tmp,swap,persistent,snapshots,boot}
cryptsetup close /dev/mapper/crypted-nixos
reboot
```

And then reboot.

## Deploying the main flake's NixOS configuration

After rebooting, we need to generate a new SSH key for the new machine, and add it to GitHub, so
that the new machine can pull my private secrets repo:

```bash
# 1. Generate a new SSH key with a strong passphrase
ssh-keygen -t ed25519 -a 256 -C "ryan@shoukei" -f ~/.ssh/shoukei
# 2. Add the ssh key to the ssh-agent, so that nixos-rebuild can use it to pull my private secrets repo.
ssh-add ~/.ssh/shoukei
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
just s-hypr
```

Finally, to enable secure boot, follow the instructions in
[lanzaboote - Quick Start](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
and
[nix-config/ai/secure-boot.nix](https://github.com/ryan4yin/nix-config/blob/main/hosts/idols_ai/secureboot.nix)
