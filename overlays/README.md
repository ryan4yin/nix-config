# Overlays

Overlays for both NixOS and Nix-Darwin.

If you don't know much about overlays, it is recommended to learn the function and usage of overlays
through [Overlays - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/nixpkgs/overlays).

## Current Structure

```
overlays/
├── README.md
├── default.nix            # Entrypoint for all overlays
├── computer-use-linux.nix # computer-use-linux from ryan4yin/nur-packages
└── cua-driver.nix         # cua-driver from ryan4yin/nur-packages
```

## Components

### 1. `default.nix`

The entrypoint imports every overlay file in this directory and applies it to the given arguments.

### 2. Package overlays

- `computer-use-linux.nix`: exposes `computer-use-linux` from the `nur-ryan4yin` flake input.
- `cua-driver.nix`: exposes `cua-driver` from the `nur-ryan4yin` flake input (used by the
  computer-use VMs).
