# Home Manager's Submodules

This directory contains all Home Manager configurations organized by platform and functionality.

## Current Structure

```
home/
├── base/              # Cross-platform home manager configurations (see base/README.md)
├── linux/             # Linux-specific home manager configurations
│   ├── base/          # Linux base configurations
│   ├── gui/           # Linux GUI applications
│   │   ├── i3/        # i3 — headless computer-use session (see i3/README.md)
│   │   ├── niri/      # Niri window manager
│   │   └── ...
│   └── ...
├── hosts/             # Host-specific home manager entry modules
│   ├── linux/         # Linux host home modules (idols-ai, 12kingdoms-shoukei, idols-kana, idols-ruby, k3s-test-1-worker-*, etc.)
│   └── darwin/        # macOS host home modules (fern, frieren)
└── darwin/            # macOS-specific home manager configurations
    ├── proxy/         # Proxy configurations
    └── ...
```

## Module Overview

1. **base**: The base module suitable for both Linux and macOS
   - Cross-platform applications and settings
   - Shared configurations for editors, shells, and essential tools

2. **linux**: Linux-specific configuration
   - Desktop environments (Noctalia Shell, Niri compositor)
   - Headless computer-use session (see `linux/gui/i3/README.md`)
   - Linux-specific GUI applications
   - System integration tools

3. **darwin**: macOS-specific configuration
   - macOS applications and services
   - Platform-specific integrations (Squirrel, etc.)

4. **hosts**: Host entry modules for Home Manager
   - Each output should reference only one host home module file
   - Host modules are responsible for importing shared stacks (`home/linux/*` or `home/darwin`) and
     applying host overrides
