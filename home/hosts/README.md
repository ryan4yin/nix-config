# Host Home Modules

This directory contains host-specific Home Manager entry modules.

## Layout

- `home/hosts/linux/*.nix`: Linux host home modules
- `home/hosts/darwin/*.nix`: macOS host home modules

## Conventions

1. Each host output should reference only one file under `home/hosts/...`.
2. The host file imports its profile's home role, see
   [Host Profiles](../../hosts/README.md#host-profiles).
   - `desktop` hosts import `../../linux/gui.nix`; `agent` hosts import `../../linux/tui.nix`.
   - Darwin hosts import `../../darwin`.
3. Host-specific overrides (SSH keys, desktop toggles, host-local config links) live in the same
   host file.
