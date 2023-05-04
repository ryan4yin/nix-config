# Nix Configuration

This repository is home to the nix code that builds my systems.


## TODO

- custom hyprland configs
  - monitor resolution - 4k
  - bar adjustment
  - vscode run in wayland mode
  - xwayland adjustment
  - references
    - https://github.com/notusknot/dotfiles-nix
    - https://wiki.hyprland.org/Configuring/Configuring-Hyprland/
    - https://github.com/notwidow/hyprland
- vscode extensions - [nix-vscode-extensions](https://github.com/nix-community/nix-vscode-extensions)
- secret management - [sops-nix](https://github.com/Mic92/sops-nix)

## Why Nix?

Nix allows for easy to manage, collaborative, reproducible deployments. This means that once something is setup and configured once, it works forever. If someone else shares their configuration, anyone can make use of it.


## How to install Nix and Deploy this Flake?

After installed NixOS with `nix-command` & `flake` enabled, you can deploy this flake with the following command:

```bash
sudo nixos-rebuild switch .#nixos-test
```

