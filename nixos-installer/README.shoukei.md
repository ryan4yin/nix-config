# Nix Environment for Deploying my NixOS Configuration

> https://wiki.t2linux.org/distributions/nixos/installation/

> https://github.com/NixOS/nixos-hardware/tree/master/apple/t2

## Steps to Deploying

First, create a USB install medium from Apple T2's NixOS installer image: https://github.com/t2linux/nixos-t2-iso.git

### 2. Connecting to the Internet

1. configure wifi: <https://wiki.t2linux.org/guides/wifi-bluetooth/#on-macos>
2. copy wifi firmware to the NixOS installer:

```bash
sudo mkdir -p /lib
sudo tar -axvf ../hosts/12kingdoms/shoukei/brcm-firmware/firmware.tar.gz -C /lib/
sudo modprobe -r brcmfmac && sudo modprobe brcmfmac

# check whether the wifi firmware is loaded
dmesg | tail

# now start wpa_supplicant
sudo systemctl start wpa_supplicant
```

connect to wifi via `wpa_cli`:

```bash
wpa_cli -i wlan0
> scan
> scan_results
# add a new network, this command returns a network ID, which is 0 in this case.
> add_network
# associate the network with the network ID we just got
# NOTE: the quotes are required!
> set_network 0 ssid "<wifi_name>"
# for a WPA2 network, set the passphrase
# NOTE: the quotes are required!
> set_network 0 psk "xxx"
# enable the network
> enable_network 0
# save the configuration file
> save_config
# show the status
> status
```

### 2. Encrypting with LUKS(everything except ESP)

Disk layout before installation:

1. `/dev/nvme0n1p1`: EFI system partition, 300MB, contains macOS's bootloader.
2. `/dev/nvme0n1p2`: macOS's root partition.
3. `/dev/nvme0n1p3`: transfer area, 10GB, used to transfer files between macOS and NixOS.
4. `/dev/nvme0n1p4`: Empty partition, used to install NixOS.

Now let's recreate the 4th partition via `fdisk`, and then encrypting the root partition:

```bash
lsblk
# show cryptsetup's compiled in defualts
cryptsetup --help

# NOTE: `cat shoukei.md | grep luks > format.sh` to generate this script
# encrypt the root partition with luks2 and argon2id, will prompt for a passphrase, which will be used to unlock the partition.
cryptsetup luksFormat --type luks2 --pbkdf argon2id --cipher aes-xts-plain64 --key-size 512 --hash sha512 /dev/nvme0n1p4

# show status
cryptsetup luksDump /dev/nvme0n1p4

# open(unlock) the device with the passphrase you just set
cryptsetup luksOpen /dev/nvme0n1p4 crypted-nixos

# show disk status
lsblk
```

Formatting the root partition:

```bash
# NOTE: `cat shoukei.md | egrep "create-btrfs"  > create-btrfs.sh` to generate this script
# format the root partition with btrfs and label it
mkfs.btrfs -L crypted-nixos /dev/mapper/crypted-nixos  # create-btrfs
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
└─nvme0n1p4       259:3    0   1.8T  0 part
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

### 3. Generating the NixOS Configuration and Installing NixOS

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
cp /etc/nixos/hardware-configuration.nix ./nix-config/hosts/12kingdoms/shoukei/hardware-configuration-new.nix
vim .
```

Then, Install NixOS:

```bash
cd ~/nix-config/hosts/12kingdoms/shoukei/nixos-installer/

# run this command if you're retrying to run nixos-install
rm -rf /mnt/etc

# install nixos
# NOTE: the root password you set here will be discarded when reboot
nixos-install --root /mnt --flake .#shoukei --no-root-password --show-trace # install-1

# if you want to use a cache mirror, run this command instead
# replace the mirror url with your own
nixos-install --root /mnt --flake .#shoukei --no-root-password --show-trace --option substituters "https://mirror.sjtu.edu.cn/nix-channels/store" # install-2

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

# delte the generated configuration after editing
rm -f /mnt/etc/nixos
rm ~/nix-config/hosts/idols/ai/hardware-configuration-new.nix

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

After rebooting, we can deploy the main flake's NixOS configuration by running:

```bash
# 1. Add the ssh key to the ssh-agent, so that nixos-rebuild can use it to pull my private git repositories.
ssh-add ~/.ssh/xxx

sudo mv /etc/nixos ~/nix-config
chown -R ryan:ryan ~/nix-config

cd ~/nix-config

# deploy the configuration
make s-hypr
```

Finally, to enable secure boot, follow the instructions in [lanzaboote - Quick Start](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md) and [nix-config/ai/secure-boot.nix](https://github.com/ryan4yin/nix-config/blob/main/hosts/idols/ai/secureboot.nix)
