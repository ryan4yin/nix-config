# Home Manager's Base Submodules

This directory contains cross-platform base configurations that are shared between Linux and Darwin
systems.

## Configuration Structure

### Core System

- **core/**: Essential cross-platform configurations
  - **core.nix**: Minimal home-manager configuration
  - **shells/**: Shell configurations (bash, Nushell; zsh is Darwin-only under `home/darwin/`)
  - **editors/**: Helix + Neovim (Home Manager) and usage docs (`README.md` per editor)
  - **btop.nix**: System monitoring tools
  - **git.nix**: Git configuration and aliases
  - **npm.nix**: Node.js package management
  - **pip.nix**: Python package management
  - **privacy.nix**: Cross-app telemetry opt-out (`DO_NOT_TRACK`)
  - **starship.nix**: Cross-shell prompt configuration
  - **theme.nix**: Color schemes and theming
  - **xdg.nix**: XDG base-directory configuration
  - **yazi.nix**: Terminal file manager configuration
  - **zellij/**: Terminal multiplexer with custom layouts

### Desktop Environment

- **gui/**: Cross-platform GUI applications and configurations
  - **dev-tools.nix**: Development tools and IDEs
  - **media.nix**: Media players and utilities
  - **zed-editor.nix**: Zed editor configuration (primary GUI editor)
  - **terminal/**: Terminal emulator configurations
    - **alacritty/**: Alacritty terminal
    - **kitty.nix**: Kitty terminal
    - **foot.nix**: Foot terminal (Linux)
    - **ghostty.nix**: Ghostty terminal

### Terminal Interface

- **tui/**: Terminal-based interface configurations
  - **agent-env.nix**: Telemetry/auto-update opt-outs for AI coding agents
  - **cloud/**: Cloud development tools (Terraform, etc.)
  - **container.nix**: Container tools (Docker, Podman)
  - **dev-tools.nix**: Terminal-based development tools
  - **editors/**: Extra terminal editor Nix (see `core/editors/` for docs and baseline enables)
  - **encryption/**: Encryption and security tools
  - **gpg/**: GPG key management
  - **herdr.nix**: Herdr agent terminal-multiplexer configuration
  - **password-store/**: Password management with pass
  - **shell/**: Shell environment configurations
  - **ssh.nix**: SSH configuration and management
  - **zellij/**: Terminal workspace management

### System Management

- **home.nix**: Main home manager configuration file

## Platform Compatibility

All configurations in this directory are designed to work across:

- **Linux**: All distributions with Nix and Home Manager
- **macOS**: Darwin systems with Home Manager
- **WSL**: Windows Subsystem for Linux

## Usage

These base configurations provide the foundation for both Linux and Darwin systems, ensuring
consistent environments across different platforms while allowing for platform-specific
customizations.
