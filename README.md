# Nix Configuration

This repository is home to the nix code that builds my systems.


## TODO

- secret management - [sops-nix](https://github.com/Mic92/sops-nix)

## Why Nix?

Nix allows for easy to manage, collaborative, reproducible deployments. This means that once something is setup and configured once, it works forever. If someone else shares their configuration, anyone can make use of it.


## How to install Nix and Deploy this Flake?

After installed NixOS with `nix-command` & `flake` enabled, you can deploy this flake with the following command:

```bash
sudo nixos-rebuild switch .#nixos-test
```

## Other Interesting Dotfiles

Other configurations from where I learned and copied:

- https://github.com/notwidow/hyprland
- https://github.com/notusknot/dotfiles-nix


