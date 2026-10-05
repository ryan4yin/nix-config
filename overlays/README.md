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
├── cua-driver.nix         # cua-driver from ryan4yin/nur-packages
└── smartctl-exporter/     # smartctl_exporter pinned to the #329 fix
    └── default.nix
```

## Components

### 1. `default.nix`

The entrypoint of overlays, it execute and import all overlay files in the current directory with
the given args.

### 2. Package overlays

- `computer-use-linux.nix`: exposes `computer-use-linux` from the `nur-ryan4yin` flake input.
- `cua-driver.nix`: exposes `cua-driver` from the `nur-ryan4yin` flake input (used by the
  computer-use VMs).
- `smartctl-exporter/`: pins `prometheus-smartctl-exporter` to the upstream commit carrying PR
  [#329](https://github.com/prometheus-community/smartctl_exporter/pull/329) until nixpkgs provides
  a version containing the fix; see `overlays/smartctl-exporter/default.nix`.
