# Nix Configuration

This repository is home to the nix code that builds my systems.


## TODO

- vscode extensions - [nix-vscode-extensions](https://github.com/nix-community/nix-vscode-extensions)
- secret management - [sops-nix](https://github.com/Mic92/sops-nix)
- switch from i3wm to hyprland
  - i3wm: old and stable, only support X11
  - sway: compatible with i3wm, support Wayland. do not support Nvidia GPU officially.
  - [hyprland](https://wiki.hyprland.org/Nix/Hyprland-on-NixOS/): project starts from 2022, support Wayland, envolving fast, good looking, support Nvidia GPU.


## Why Nix?

Nix allows for easy to manage, collaborative, reproducible deployments. This means that once something is setup and configured once, it works forever. If someone else shares their configuration, anyone can make use of it.


## How to install Nix and Deploy this Flake?

After installed NixOS with `nix-command` & `flake` enabled, you can deploy this flake with the following command:

```bash
sudo nixos-rebuild switch .#nixos-test
```

