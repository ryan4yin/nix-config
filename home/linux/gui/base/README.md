# Base Desktop Environment Configuration

This directory contains base configurations for Linux desktop environments, providing essential
components for a complete Wayland desktop experience.

## Overview

The configuration is organized into modular components that can be selectively enabled:

- **Desktop Shell**: Noctalia Shell for unified desktop environment
- **Applications**: Desktop tools, browsers, editors, media players, etc.
- **Development Tools**: IDEs and development utilities
- **System Integration**: Input methods, theming, XDG specifications, GPU settings

## Noctalia

**Noctalia** (v5) is a native C++/Wayland all-in-one desktop shell that replaces multiple separate
tools with a single, unified solution. It is installed and configured through the upstream
[`programs.noctalia`](https://docs.noctalia.dev/noctalia/getting-started/nixos/) Home Manager
module, which validates the TOML at build time.

### Configuration

Noctalia merges **every `*.toml` in the config directory** (`~/.config/noctalia/`), sorted
alphabetically, and then layers the Settings UI's own overrides on top:

| Layer                | Location                                                          | Notes                                           |
| -------------------- | ----------------------------------------------------------------- | ----------------------------------------------- |
| Declarative baseline | `~/.config/noctalia/*.toml` (repo: `noctalia/config/config.toml`) | Merged alphabetically; `[include]` supported    |
| GUI overrides        | `~/.local/state/noctalia/settings.toml`                           | Written by the Settings UI; loads last and wins |

`noctalia config export merged` prints the effective user config and `noctalia config validate`
checks a file. Application theming stays with `catppuccin/nix`, so Noctalia's theme templates are
disabled.

### Component Replacement

Noctalia consolidates functionality that previously required multiple tools:

| Traditional Component  | Purpose                  | Noctalia counterpart                              |
| ---------------------- | ------------------------ | ------------------------------------------------- |
| **gammastep**          | Blue light filter        | `[nightlight]`                                    |
| **swaylock**           | Screen locker            | built-in lock screen (`[lockscreen]`)             |
| **anyrun**             | Application launcher     | launcher panel (`[shell.launcher]`)               |
| **mako**               | Notification daemon      | `[notification]`                                  |
| **waybar**             | Status bar               | `[bar]` + `[widget.*]`                            |
| **wallpaper-switcher** | Wallpaper management     | `[wallpaper]`                                     |
| **wlogout**            | Session menu             | `[shell.session]`                                 |
| **wl-clipboard**       | Clipboard management     | built-in clipboard (encrypted history)            |
| **grim/slurp/satty**   | Screenshots + annotation | built-in `[shell.screenshot]` + annotation editor |

## Configuration Modules

### Desktop Shell

- **[`noctalia/default.nix`](./noctalia/default.nix)**: enables the upstream `programs.noctalia`
  module
- **[`noctalia/config/config.toml`](./noctalia/config/config.toml)**: declarative baseline (v5 TOML)

  Key features: bar and widgets, control center, desktop widgets, night light, wallpaper, session
  panel, screenshots with annotation, system monitor, audio/volume, brightness, calendar/weather,
  color schemes, dock, notifications, OSD, clipboard, and more.

- **[`hypridle/`](./hypridle/)**: Idle management

### Desktop Environment

- **[`gtk.nix`](./gtk.nix)**: GTK theme configuration
- **[`xdg/`](./xdg/)**: XDG specifications

### Input & Localization

- **[`fcitx5/`](./fcitx5/)**: Fcitx5 input method with Mozc (Japanese input)

### Applications

- **[`desktop-tools.nix`](./desktop-tools.nix)**: Wayland session tools (clipboard, color picker,
  brightness, audio, screen recording, auto-mount, `wlogout` emergency fallback)
- **[`browsers.nix`](./browsers.nix)**: Web browsers
- **[`vscode.nix`](./vscode.nix)**: VS Code (GUI editor; the primary Zed config is shared from
  [`home/base/gui/zed-editor.nix`](../../../base/gui/zed-editor.nix))
- **[`media.nix`](./media.nix)**: Media players
- **[`gaming.nix`](./gaming.nix)**: Gaming applications
- **[`creative.nix`](./creative.nix)**: Creative software
- **[`note-taking.nix`](./note-taking.nix)**: Note-taking apps

### Development

- **[`dev-tools.nix`](./dev-tools.nix)**: Development tools and IDEs

### System Utilities

- **[`misc.nix`](./misc.nix)**: Misc GUI apps (e-book reader, remote desktop, hardened IM clients)
- **[`immutable-file.nix`](./immutable-file.nix)**: Immutable file handling

## Related Documentation

- Noctalia Shell: https://docs.noctalia.dev/noctalia/
- Parent: [`../README.md`](../README.md)
