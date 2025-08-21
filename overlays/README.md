# Overlays

Overlays for both NixOS and Nix-Darwin.

If you don't know much about overlays, it is recommended to learn the function and usage of overlays
through [Overlays - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/nixpkgs/overlays).

## Current Structure

```
overlays/
├── README.md
├── default.nix          # Entrypoint for all overlays
└── fcitx5/              # Chinese input method configuration
    ├── README.md
    ├── default.nix      # fcitx5 overlay definition
    └── rime-data-flypy/ # Custom rime data for 小鹤音形输入法
        └── share/
            └── rime-data/
                ├── build/
                ├── default.custom.yaml
                ├── default.yaml
                ├── flypy.schema.yaml
                ├── flypy_full全码字.txt
                ├── flypy_sys.txt
                ├── flypy_top.txt
                ├── flypy_user.txt
                ├── lua/
                │   └── calculator_translator.lua
                ├── rime.lua
                ├── squirrel.custom.yaml
                └── squirrel.yaml
```

## Components

### 1. `default.nix`

The entrypoint of overlays, it execute and import all overlay files in the current directory with
the given args.

### 2. `fcitx5`

fcitx5's overlay, add my customized Chinese input method - [小鹤音形输入法](https://flypy.com/)

This overlay provides:

- Custom rime data for 小鹤音形输入法 (Flypy input method)
- Cross-platform support for both Linux (fcitx5-rime) and macOS (squirrel)
- Pre-configured input method settings
