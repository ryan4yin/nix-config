# Library

Some Helper functions for the project:

1. `macosSystem.nix`: A function to generate attribute set for macOS([nix-darwin](https://github.com/LnL7/nix-darwin)), used by `flake.nix` to reduce code duplication and make it easier to add new machines.
2. `nixosSystem.nix`: A function to generate attribute set for NixOS, used by `flake.nix` to reduce code duplication and make it easier to add new machines.
3. `colmenaSystem.nix`: A function to generate attribute set for remote deployment using [colmena](https://github.com/zhaofengli/colmena), used by `flake.nix` to reduce code duplication and make it easier to add new machines.

