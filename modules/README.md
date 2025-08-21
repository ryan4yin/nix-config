# NixOS / Nix-Darwin's Submodules

This directory contains modular NixOS and Nix-Darwin configurations organized by platform and
functionality.

## Current Structure

```
modules/
├── README.md
├── base/                    # Common configuration for all platforms
│   ├── default.nix
│   ├── fonts.nix           # System font configuration
│   ├── nix.nix            # Nix package manager settings
│   ├── overlays.nix       # Package overlays
│   ├── security.nix       # Basic security settings
│   ├── system-packages.nix # Essential system packages
│   └── users.nix          # User management
├── darwin/                  # macOS-specific modules
│   ├── README.md
│   ├── apps.nix           # macOS applications
│   ├── broken-packages.nix # Package compatibility fixes
│   ├── default.nix
│   ├── nix-core.nix       # Core Nix configuration
│   ├── security.nix       # macOS security settings
│   ├── ssh.nix           # SSH configuration
│   ├── system.nix        # System-level settings
│   └── users.nix         # macOS user management
└── nixos/                   # NixOS-specific modules
    ├── base/               # Base NixOS configuration
    │   ├── btrbk.nix      # Backup configuration
    │   ├── core.nix       # Core system settings
    │   ├── default.nix
    │   ├── i18n.nix       # Internationalization
    │   ├── monitoring.nix # System monitoring
    │   ├── networking.nix # Network configuration
    │   ├── nix.nix        # Nix settings
    │   ├── packages.nix   # System packages
    │   ├── remote-building.nix # Remote build setup
    │   ├── ssh.nix        # SSH daemon configuration
    │   ├── user-group.nix # User and group management
    │   └── zram.nix       # ZRAM swap configuration
    ├── desktop.nix         # Desktop environment configuration
    ├── desktop/            # Desktop-specific modules
    │   ├── default.nix
    │   ├── fhs.nix        # FHS environment
    │   ├── fonts.nix      # Desktop fonts
    │   ├── guix.nix       # GNU Guix integration
    │   ├── misc.nix       # Miscellaneous desktop settings
    │   ├── networking/    # Network-related desktop configs
    │   │   ├── clash-verge.nix
    │   │   ├── default.nix
    │   │   ├── remote-desktop.nix
    │   │   └── tailscale.nix
    │   ├── peripherals.nix # Peripheral device configuration
    │   ├── security.nix   # Desktop security settings
    │   ├── virtualisation.nix # Virtualization support
    │   └── xdg.nix       # XDG base directory settings
    └── server/             # Server-specific modules
        ├── kubevirt-hardware-configuration.nix
        ├── server-aarch64.nix
        ├── server-riscv64.nix
        └── server.nix
```

## Module Categories

### 1. **Base Modules** (`base/`)

Common configuration shared between NixOS and macOS:

- System fonts and localization
- Essential packages and tools
- Basic security settings
- User management
- Package overlays

### 2. **macOS Modules** (`darwin/`)

macOS-specific configuration:

- macOS applications and system settings
- Security configurations tailored for macOS
- SSH and system-level settings
- Package compatibility fixes

### 3. **NixOS Modules** (`nixos/`)

Platform-specific NixOS configuration:

- **Base**: Core system settings and services
- **Desktop**: Desktop environment and GUI applications
- **Server**: Server-specific optimizations and services

## Usage

Modules are imported based on platform detection:

- **NixOS Systems**: Import `nixos/` modules
- **macOS Systems**: Import `darwin/` modules
- **All Systems**: Import `base/` modules for shared configuration

## Architecture Support

- **x86_64-linux**: Desktop and server configurations
- **aarch64-linux**: ARM64 Linux systems
- **aarch64-darwin**: Apple Silicon macOS systems
- **server-riscv64**: RISC-V server configurations
