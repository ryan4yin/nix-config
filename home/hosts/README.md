# Host Home Modules

This directory contains host-specific Home Manager entry modules.

## Layout

- `home/hosts/linux/*.nix`: Linux host home modules
- `home/hosts/darwin/*.nix`: macOS host home modules

## Conventions

1. Each host output should reference only one file under `home/hosts/...`.
2. Shared home module imports should be handled in the host file itself.
   - Linux hosts usually import `../../linux/core.nix` or `../../linux/gui.nix`.
   - Darwin hosts import `../../darwin`.
3. Host-specific overrides (SSH keys, desktop toggles, host-local config links) live in the same
   host file.
