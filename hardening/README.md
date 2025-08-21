# Linux Hardening

> Work in progress.

## Goal

- **System Level**: Protect critical files from being accessed by untrusted applications.
  1. Such as browser cookies, SSH keys, etc.
- **Per-App Level**: Prevent untrusted applications(such as closed-source apps) from:
  1. Accessing files they shouldn't.
     - Such as a malicious application accessing your browser's cookies, SSH Keys, etc.
  1. Accessing the network when they don't need to.
  1. Accessing hardware devices they don't need.

## Current Structure

### 1. **System Level**

- **AppArmor** (`apparmor/`): AppArmor profiles and configuration
- **Kernel & System Hardening** (`profiles/`): System-wide hardening profiles

### 2. **Per-App Level**

- **Nixpak** (`nixpaks/`): Bubblewrap-based sandboxing for applications
  - Firefox configuration
  - QQ (Chinese messaging app) configuration
  - Modular system with reusable components
- **Firejail** (legacy): SUID-based sandboxing (not used)
- **Bubblewrap** (`bwraps/`): Direct bubblewrap configurations
  - WeChat sandboxing configuration

## Current Implementation Status

| Component         | Status    | Notes                          |
| ----------------- | --------- | ------------------------------ |
| AppArmor Profiles | 🚧 WIP    | Basic structure in place       |
| Nixpak Firefox    | ✅ Active | Firefox sandboxing via nixpak  |
| Nixpak QQ         | ✅ Active | QQ application sandboxing      |
| Bubblewrap WeChat | ✅ Active | WeChat specific sandboxing     |
| System Profiles   | 🚧 WIP    | Hardened system configurations |

## Directory Structure

```
hardening/
├── README.md
├── apparmor/           # AppArmor security profiles
│   └── default.nix
├── bwraps/            # Direct bubblewrap configurations
│   ├── default.nix
│   └── wechat.nix
├── nixpaks/           # Nixpak application sandboxing
│   ├── default.nix
│   ├── firefox.nix
│   ├── firefox-desktop-item.nix
│   ├── qq.nix
│   ├── qq-desktop-item.nix
│   └── modules/       # Reusable nixpak modules
│       ├── gui-base.nix
│       └── network.nix
└── profiles/          # System hardening profiles
    └── default.nix
```

## Kernel Hardening

- NixOS Kernel Config:
  https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/hardened/config.nix

## System Hardening

- NixOS Profile:
  https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/profiles/hardened.nix
- Apparmor: [roddhjav/apparmor.d](https://github.com/roddhjav/apparmor.d)
  - https://gitlab.com/apparmor/apparmor/-/wikis/Documentation
  - AppArmor.d is a set of over 1500 AppArmor profiles whose aim is to confine most Linux based
    applications and processes.
  - But all the profiles of AppArmor assume a FHS filesystem, which caused all apparmor policies
    takes no effect on NixOS.
  - Apparmor on NixOS Roadmap:
    - https://discourse.nixos.org/t/apparmor-on-nixos-roadmap/57217
    - https://github.com/LordGrimmauld/aa-alias-manager
- SELinux: too complex, not recommended for personal use.

## Application Sandboxing

- [Bubblewrap](https://github.com/containers/bubblewrap):
  [nixpak](https://github.com/nixpak/nixpak), more secure than firejail, but no batteries included.
  - NixOS's FHSEnv is implemented using bubblewrap by default.
- [Firejail](https://github.com/netblue30/firejail/tree/master/etc): A SUID security sandbox with
  hundreds of security profiles for many common applications in the default installation.
  - https://wiki.nixos.org/wiki/Firejail
  - Firejail needs SUID to work, which is considered a security risk -
    [Does firejail improve the security of my system?](https://github.com/netblue30/firejail/discussions/4601)
- [Systemd/Hardening](https://wiki.nixos.org/wiki/Systemd/Hardening): Systemd also provides some
  sandboxing features.

## NOTE

**Running untrusted code is never safe, kernel hardening & sandboxing cannot change this**.

If you want to run untrusted code, please use a VM & an isolated network environment, which will
provide a much higher level of security.

## References

- [Harden your NixOS workstation - dataswamp](https://dataswamp.org/~solene/2022-01-13-nixos-hardened.html)
- [Linux Insecurities - Madaidans](https://madaidans-insecurities.github.io/linux.html)
- [Sandboxing all programs by default - NixOS Discourse](https://discourse.nixos.org/t/sandboxing-all-programs-by-default/7792)
- [Paranoid NixOS Setup - xeiaso](https://xeiaso.net/blog/paranoid-nixos-2021-07-18/)
- [nix-mineral](https://github.com/cynicsketch/nix-mineral): NixOS module for convenient system
  hardening.
- nixpak configs:
  - https://github.com/pokon548/OysterOS/tree/b97604d89953373d6316286b96f6a964af2c398d/desktop/application
  - https://github.com/segment-tree/my-nixos/tree/ceb6041f73bd9edcb78a8818b27a28f7c629193b/hm/me/apps/nixpak
  - https://github.com/Keksgesicht/nixos-config/tree/91cc77d8d6b598da7c4dbed143e0009c2dea6940/packages/nixpak
  - https://github.com/bluskript/nix-config/blob/7ecb6a7254c1ac4969072f4c4febdc19f8b83b30/pkgs/nixpak/default.nix
- firejail configs:
  - https://github.com/stelcodes/nixos-config/blob/f8967c82a5e5f3d128eb1aaf7498b5f918f719ec/packages/overlay.nix#L261
- apparmor configs:
  - https://github.com/zramctl/dotfiles/blob/4fe177f6984154960942bb47d5a375098ec6ed6a/modules/nixos/security/apparmor.nix#L4
  - https://git.grimmauld.de/Grimmauld/grimm-nixos-laptop/src/branch/main/hardening
- Others:
  - Directly via `buildFHSUserEnvBubblewrap`:
