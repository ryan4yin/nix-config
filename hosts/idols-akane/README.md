# Idols - Akane

VM running on macOS's UTM App.

Steps to install:

```bash
# 1. format & mount the filesystem
nix-shell -p disko
sudo disko --mode destroy,format,mount hosts/idols-akane/disko-fs.nix

# 2. install nixos
nixos-install --root /mnt --flake .#akane --no-root-password --show-trace --verbose --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store  https://cache.nixos.org/" # install-2

# enter into the installed system, check password & users
# `su ryan` => `sudo -i` => enter ryan's password => successfully login
# if login failed, check the password you set in install-1, and try again
nixos-enter

reboot
```
