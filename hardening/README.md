# Linux Hardening

## Goal

1. Prevent applications from accessing files they shouldn't.
   - Such as a malicious application accessing your browser's cookies, SSH Keys, etc.
2. Prevent applications from accessing the network they shouldn't.
3. Prevent applications from accessing hardware devices they don't need.

## Kernel Hardening

- NixOS Kernel Config:
  https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/hardened/config.nix

## System Hardening

- NixOS Profile:
  https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/profiles/hardened.nix
- Apparmor: [roddhjav/apparmor.d)](https://github.com/roddhjav/apparmor.d)
  - AppArmor.d is a set of over 1500 AppArmor profiles whose aim is to confine most Linux based
    applications and processes.
  - Nix Package:
    [roddhjav-apparmor-rules](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ro/roddhjav-apparmor-rules/package.nix#L33)
  - https://github.com/NixOS/nixpkgs/issues/331645
- SELinux: too complex, not recommended for personal use.

## Application Sandboxing

- [Firejail](https://github.com/netblue30/firejail/tree/master/etc): A SUID security sandbox with
  hundreds of security profiles for many common applications in the default installation.
- Bubblewrap: [nixpak](https://github.com/nixpak/nixpak), more secure than firejail, but no
  batteries included.
  - NixOS's FHSEnv is implemented using bubblewrap by default.

## NOTE

**Running untrusted code is never safe, kernel hardening & sandboxing cannot change this**.

If you want to run untrusted code, please use a VM & an isolated network environment, which will
provide a much higher level of security.

## References

- [Harden your NixOS workstation - dataswamp](https://dataswamp.org/~solene/2022-01-13-nixos-hardened.html)
- [Linux Insecurities - Madaidans](https://madaidans-insecurities.github.io/linux.html)
- NixOS Configs:
  - https://github.com/segment-tree/my-nixos/tree/ceb6041f73bd9edcb78a8818b27a28f7c629193b/hm/me/apps/nixpak
  - https://github.com/Keksgesicht/nixos-config/tree/91cc77d8d6b598da7c4dbed143e0009c2dea6940/packages/nixpak
  - https://github.com/bluskript/nix-config/blob/7ecb6a7254c1ac4969072f4c4febdc19f8b83b30/pkgs/nixpak/default.nix
