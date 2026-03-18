# Disko Config

## Partition the SSD & install NixOS via disko

```bash
# enter an shell with git/vim/ssh-agent/gnumake available
nix-shell -p git vim gnumake
# clone this repository
git clone https://github.com/ryan4yin/nix-config.git

cd nix-config

## 1. partition & format the disk via disko
# encrypt the root partition with luks2 and argon2id, will prompt for a passphrase, which will be used to unlock the partition.
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode destroy,format,mount hosts/k8s/disko-config/kubevirt-disko-fs.nix
## 2. setup the automatic unlock via the tpm2 chip
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/<encrypted-disk-part-path>

## 3. install nixos
sudo nixos-install --root /mnt --no-root-password --show-trace --verbose --flake .#kubevirt-shoryu

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
mkdir -p /persistent/home/ryan
chown -R ryan:ryan /persistent/home/ryan

# add your k3s token at /persistent/kubevirt-k3s-token
```
