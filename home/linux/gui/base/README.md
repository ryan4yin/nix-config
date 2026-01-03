# Base Desktop Environment Configuration

This directory contains base configurations for Linux desktop environments, providing essential
components for a complete Wayland desktop experience.

## Overview

The configuration is organized into modular components that can be selectively enabled:

- **Desktop Shell**: Noctalia Shell for unified desktop environment
- **Applications**: Desktop tools, browsers, editors, media players, etc.
- **Development Tools**: IDEs and development utilities
- **System Integration**: Input methods, theming, XDG specifications, GPU settings

## Noctalia Shell

**Noctalia Shell** is an all-in-one Wayland desktop shell that replaces multiple separate tools with
a single, unified solution. It provides:

- **Unified Configuration**: All components configured in a single `settings.json` file
- **Consistent Experience**: Cohesive visual design and interaction patterns
- **Reduced Complexity**: No need to maintain multiple separate config files

### Component Replacement

Noctalia Shell consolidates functionality that previously required multiple tools:

| Traditional Component  | Purpose              | Noctalia Replacement           |
| ---------------------- | -------------------- | ------------------------------ |
| **gammastep**          | Blue light filter    | `nightLight` configuration     |
| **swaylock**           | Screen locker        | Built-in lock screen           |
| **anyrun**             | Application launcher | `appLauncher`                  |
| **mako**               | Notification daemon  | `notifications`                |
| **waybar**             | Status bar           | `bar` (with widgets)           |
| **wallpaper-switcher** | Wallpaper management | `wallpaper` (with transitions) |
| **wlogout**            | Session menu         | `sessionMenu`                  |
| **wl-clipboard**       | Clipboard management | Built-in clipboard manager     |

## Configuration Modules

### Desktop Shell

- **[`noctalia/default.nix`](./noctalia/default.nix)**: Package installation and systemd service
- **[`noctalia/settings.json`](./noctalia/settings.json)**: Main configuration with all settings

  Key features: bar, control center, night light, wallpaper, session menu, system monitor,
  audio/volume, brightness, screen recorder, calendar, color schemes, dock, notifications, OSD, and
  more.

- **[`hypridle/`](./hypridle/)**: Idle management

### Desktop Environment

- **[`gtk.nix`](./gtk.nix)**: GTK theme configuration
- **[`xdg.nix`](./xdg.nix)**: XDG specifications
- **[`nvidia.nix`](./nvidia.nix)**: NVIDIA GPU settings

### Input & Localization

- **[`fcitx5/`](./fcitx5/)**: Fcitx5 input method with Mozc (Japanese input)

### Applications

- **[`desktop-tools.nix`](./desktop-tools.nix)**: Daily GUI apps (foliate, remmina, messaging)
- **[`browsers.nix`](./browsers.nix)**: Web browsers
- **[`editors.nix`](./editors.nix)**: Desktop text editors
- **[`media.nix`](./media.nix)**: Media players
- **[`gaming.nix`](./gaming.nix)**: Gaming applications
- **[`creative.nix`](./creative.nix)**: Creative software
- **[`note-taking.nix`](./note-taking.nix)**: Note-taking apps

### Development

- **[`dev-tools.nix`](./dev-tools.nix)**: Development tools and IDEs

### System Utilities

- **[`misc.nix`](./misc.nix)**: Wayland tools (screenshots, screen recording, color picker, audio)
- **[`immutable-file.nix`](./immutable-file.nix)**: Immutable file handling

## Related Documentation

- Noctalia Shell: https://docs.noctalia.dev/docs
- Parent: [`../README.md`](../README.md)
