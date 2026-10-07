# Library

This directory contains helper functions used by `outputs/default.nix` (and the installer flake) to
reduce code duplication and make it easier to add new machines.

## Current Functions

### Core System Generators

1. **`macosSystem.nix`** - macOS configuration generator for
   [nix-darwin](https://github.com/LnL7/nix-darwin)
2. **`nixosSystem.nix`** - NixOS configuration generator
3. **`colmenaSystem.nix`** - Remote deployment configuration for
   [colmena](https://github.com/nix-community/colmena)

### Specialized Module Generators

4. **`genK3sServerModule.nix`** - K3s server node configuration generator
5. **`genK3sAgentModule.nix`** - K3s agent/worker node configuration generator
6. **`genVmHostModule.nix`** - physical VM host (bridge + libvirt) configuration generator
7. **`genMicrovmGuestModule.nix`** - NixOS microVM guest configuration generator
8. **`genLibvirtDomainXml.nix`** - libvirt domain XML generator (imported directly by host configs)

### Entry Point

9. **`default.nix`** - Main entry point that imports the generators and exports them as a single
   attribute set, plus the `relativeToRoot` and `scanPaths` helpers

## Usage

The generators import the shared host modules, so a new machine supplies its own values and
system-specific attributes. `colmenaSystem` covers remote deployment, and `genLibvirtDomainXml`
renders the domain XML for one guest.

## Architecture Support

- **x86_64-linux**: Primary desktop systems
- **aarch64-linux**: ARM64 Linux systems (Apple Silicon, SBCs)
- **aarch64-darwin**: Apple Silicon macOS systems
