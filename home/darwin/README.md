# Home Manager's Darwin Submodules

This directory contains macOS-specific Home Manager configurations for Darwin systems.

## Configuration Modules

### Core Configurations

- **default.nix**: Entry point that imports all Darwin configurations
- **shell.nix**: Shell configurations and environment settings
- **terminal.nix**: Sets a 15px font size across Ghostty and Kitty

### Network Configuration

- **proxy/**: Network proxy configurations
  - `proxychains.conf`: Proxy chains configuration for network routing
  - Proxy settings for development tools and applications

## Features

- macOS-specific package installations and configurations
- macOS-specific shell configurations (Homebrew's `bin` directories on `PATH` for bash and zsh)

System-level macOS settings live in the nix-darwin modules: Touch ID for `sudo` in
[`modules/darwin/system.nix`](../../modules/darwin/system.nix), and native applications and Homebrew
packages in [`modules/darwin/apps.nix`](../../modules/darwin/apps.nix).
