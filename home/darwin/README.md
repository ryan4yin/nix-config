# Home Manager's Darwin Submodules

This directory contains macOS-specific Home Manager configurations for Darwin systems.

## Configuration Modules

### Core Configurations

- **default.nix**: Entry point that imports all Darwin configurations
- **shell.nix**: Shell configurations and environment settings
- **rime-squirrel.nix**: [Rime Squirrel](https://github.com/rime/squirrel) input method
  configuration

### Network Configuration

- **proxy/**: Network proxy configurations
  - `proxychains.conf`: Proxy chains configuration for network routing
  - Proxy settings for development tools and applications

## Features

- macOS-specific package installations and configurations
- Native macOS applications and utilities
- Touch ID and system integration
- Homebrew integration for additional packages
- macOS-specific shell configurations and aliases
