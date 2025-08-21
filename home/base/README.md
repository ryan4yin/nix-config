# Home Manager's Base Submodules

This directory contains cross-platform base configurations that are shared between Linux and Darwin
systems.

## Configuration Structure

### Core System

- **core/**: Essential cross-platform configurations
  - **core.nix**: Minimal home-manager configuration
  - **shells/**: Shell configurations (bash, zsh, fish, nu)
  - **editors/**: Text editor configurations
    - **neovim/**: Neovim with custom plugins and settings
    - **helix/**: Helix editor configuration
  - **btop.nix**: System monitoring tools
  - **git.nix**: Git configuration and aliases
  - **npm.nix**: Node.js package management
  - **pip.nix**: Python package management
  - **starship.nix**: Cross-shell prompt configuration
  - **theme.nix**: Color schemes and theming
  - **yazi.nix**: Terminal file manager configuration
  - **zellij/**: Terminal multiplexer with custom layouts

### Desktop Environment

- **gui/**: Cross-platform GUI applications and configurations
  - **dev-tools.nix**: Development tools and IDEs
  - **media.nix**: Media players and utilities
  - **terminal/**: Terminal emulator configurations
    - **alacritty/**: Alacritty terminal
    - **kitty/**: Kitty terminal
    - **foot/**: Foot terminal (Linux)
    - **ghostty/**: Ghostty terminal

### Terminal Interface

- **tui/**: Terminal-based interface configurations
  - **cloud/**: Cloud development tools (Terraform, etc.)
  - **container.nix**: Container tools (Docker, Podman)
  - **dev-tools.nix**: Terminal-based development tools
  - **editors/**: Terminal editor configurations
  - **encryption/**: Encryption and security tools
  - **gpg/**: GPG key management
  - **password-store/**: Password management with pass
  - **shell.nix**: Shell environment configurations
  - **ssh/**: SSH configuration and management
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
