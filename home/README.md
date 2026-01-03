# Home Manager's Submodules

This directory contains all Home Manager configurations organized by platform and functionality.

## Current Structure

```
home/
├── base/              # Cross-platform home manager configurations
│   ├── core/          # Essential applications and settings
│   │   ├── editors/   # Editor configurations (Neovim, Helix)
│   │   ├── shells/    # Shell configurations (Nushell, Zellij)
│   │   └── ...
│   ├── gui/           # GUI applications and desktop settings
│   │   ├── terminal/  # Terminal emulators (Kitty, Alacritty, etc.)
│   │   └── ...
│   ├── tui/           # Terminal/TUI applications
│   │   ├── editors/   # TUI editors and related tools
│   │   ├── encryption/ # GPG, password-store, etc.
│   │   └── ...
│   └── home.nix       # Main home manager entry point
├── linux/             # Linux-specific home manager configurations
│   ├── base/          # Linux base configurations
│   ├── gui/           # Linux GUI applications
│   │   ├── niri/      # Niri window manager
│   │   └── ...
│   ├── editors/       # Linux-specific editors
│   └── ...
└── darwin/            # macOS-specific home manager configurations
    ├── aerospace/     # macOS window manager
    ├── proxy/         # Proxy configurations
    └── ...
```

## Module Overview

1. **base**: The base module suitable for both Linux and macOS
   - Cross-platform applications and settings
   - Shared configurations for editors, shells, and essential tools

2. **linux**: Linux-specific configuration
   - Desktop environments (Noctalia Shell, Niri compositor)
   - Linux-specific GUI applications
   - System integration tools

3. **darwin**: macOS-specific configuration
   - macOS applications and services
   - Platform-specific integrations (Aerospace, Squirrel, etc.)
