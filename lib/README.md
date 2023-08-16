# Library

Some helper functions, used by `flake.nix` to reduce code duplication and make it easier to add new machines:

1. `macosSystem.nix`: A function to generate config(attribute set) for macOS([nix-darwin](https://github.com/LnL7/nix-darwin)).
2. `nixosSystem.nix`: A function to generate config(attribute set) for NixOS.
3. `colmenaSystem.nix`: A function that generate config(another function) for remote deployment using [colmena](https://github.com/zhaofengli/colmena).

