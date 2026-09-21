# Desktop Environment Configurations

This directory contains desktop environment and window manager configurations managed by Home
Manager.

## Available Configurations

### Window Managers

- **niri**: Niri compositor configuration with custom settings, keybindings, spawn-at-startup rules,
  and window rules
- **i3**: Headless X11 session for the computer-use VMs (`idols-ruby`, `idols-kana`); see
  [`i3/README.md`](./i3/README.md)

### Base Desktop Environment

- **base**: Common desktop configurations shared across all environments, including:
  - **Noctalia**: native (v5) all-in-one Wayland desktop shell (replaces gammastep, swaylock,
    anyrun, mako, waybar, wallpaper-switcher, wlogout, grim/slurp/satty, and other desktop tools)
  - Creative tools and media applications
  - Development tools
  - Fcitx5 input method framework
  - Games and gaming utilities
  - GTK theme configurations
  - Immutable file handling
  - Note-taking applications
  - Wayland applications
  - XDG desktop configurations

## Why install Desktop Environments in Home Manager instead of NixOS Module?

1. **Configuration Location**: Desktop environment configuration files are located in `~/.config`,
   which can be easily managed by Home Manager.

2. **User-specific Services**: User-specific systemd services (fcitx5, hypridle, etc.) can be easily
   managed by Home Manager. If desktop environments were configured via NixOS Module, these
   user-level services might fail to start automatically. With Home Manager modules, we can control
   systemd service dependency order more effectively.

3. **System Benefits**: By minimizing package installation through NixOS Module:
   - Makes the NixOS system more secure and stable
   - Increases portability to non-NixOS systems, as Home Manager can be installed on any Linux
     system
   - Allows for easier switching between different window managers without system-level changes
