# Overlays

Overlays for both NixOS and Nix-Darwin.

If you don't know much about overlays, it is recommended to learn the function and usage of overlays
through [Overlays - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/nixpkgs/overlays).

## Current Structure

```
overlays/
├── README.md
├── default.nix            # Entrypoint for all overlays
└── nur-ryan4yin.nix       # ryan4yin/nur-packages
```

## Components

### 1. `default.nix`

The entrypoint imports every overlay file in this directory and applies it to the given arguments.

### 2. Package overlays

- `nur-ryan4yin.nix`: applies the `nur-ryan4yin` input's own overlay, which adds `dsh`,
  `rime-data-flypy`, `computer-use-linux` and `cua-driver` to `pkgs`.
