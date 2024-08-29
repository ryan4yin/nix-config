# Linux Hardening

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

## References

- [Harden your NixOS workstation - dataswamp](https://dataswamp.org/~solene/2022-01-13-nixos-hardened.html)
- [Linux Insecurities - Madaidans](https://madaidans-insecurities.github.io/linux.html)
