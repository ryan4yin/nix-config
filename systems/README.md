# Systems

As the configuration was constantly updated, my `flake.nix` gradually became bloated, so I split the system-related logic here from flake.nix.

- `default.nix`: Some specialArgs and other parameters common to all systems are defined here, and all other nix files in this folder are imported here.
- `colmena.nix`: My NixOS servers deployed via colmena.
- `darwin.nix`: My Macbooks
- `nixos.nix`: My NixOS desktops & servers.


