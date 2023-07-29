# Overlays

Overlays for both NixOS and Nix-Darwin.

If you don't know much about overlays, it is recommended to learn the function and usage of overlays through [Overlays - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/nixpkgs/overlays).

1. `default.nix`: the entrypoint of overlays, it execute and import all overlay files in the current directory with the given args.
2. `fcitx5`: fcitx5's overlay, add my customized Chinese input method - [小鹤音形输入法](https://flypy.com/)

