# Disko Config

Generate LUKS keyfile to encrypt the root partition, it's used by disko.

```bash
# partition the usb stick
DEV=/dev/sdX
parted $DEV -- mklabel gpt
parted $DEV -- mkpart primary 2M 512MB
parted $DEV -- mkpart primary 512MB 1024MB
mkfs.fat -F 32 -n NIXOS_DSC ${DEV}1
mkfs.fat -F 32 -n NIXOS_K3S ${DEV}2

# Generate a keyfile from the true random number generator
KEYFILE=./kubevirt-luks-keyfile
dd bs=512 count=64 iflag=fullblock if=/dev/random of=$KEYFILE

# generate token for k3s
K3S_TOKEN_FILE=./kubevirt-k3s-token
K3S_TOKEN=$(grep -ao '[A-Za-z0-9]' < /dev/random | head -64 | tr -d '\n' ; echo "")
echo $K3S_TOKEN > $K3S_TOKEN_FILE

# copy the keyfile and token to the usb stick
KEYFILE=./kubevirt-luks-keyfile
DEVICE=/dev/disk/by-label/NIXOS_DSC
# seek=128 skip N obs-sized output blocks to avoid overwriting the filesystem header
dd bs=512 count=64 iflag=fullblock seek=128 if=$KEYFILE of=$DEVICE

K3S_TOKEN_FILE=./kubevirt-k3s-token
USB_PATH=/run/media/ryan/NIXOS_K3S
cp $K3S_TOKEN_FILE $USB_PATH
```

### 2. Partition the SSD & install NixOS via disko

```bash
# enter an shell with git/vim/ssh-agent/gnumake available
nix-shell -p git vim gnumake
# clone this repository
git clone https://github.com/ryan4yin/nix-config.git

cd nix-config

# one line
sudo nix run --experimental-features "nix-command flakes" 'github:nix-community/disko#disko-install' -- \
  --write-efi-boot-entries --disk main /dev/nvme0n1 --flake .#kubevirt-shoryu


# or step by step
## 1. partition & format the disk via disko
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko hosts/k8s/disko-config/kukubevirt-disko-fs.nix
## 2. install nixos
sudo nixos-install --root /mnt --no-root-password --show-trace --verbose --flake .#kubevirt-shoryu

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
