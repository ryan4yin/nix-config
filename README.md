# Nix Configuration

This repository is home to the nix code that builds my systems.


## Screenshots

![](./_img/screenshot_2023-05-07-21-21.webp)

## TODO

- [sops-nix](https://github.com/Mic92/sops-nix): secret management
- [devShell](https://github.com/numtide/devshell): manage development environments

## Why Nix?

Nix allows for easy to manage, collaborative, reproducible deployments. This means that once something is setup and configured once, it works forever. If someone else shares their configuration, anyone can make use of it.


## How to Deploy this Flake?

>Note: you should NOT deploy this flake directly on your machine, it contains my hardware information and personal information which is not suitable for you. You may use this repo as a reference to build your own configuration.

After installed NixOS with `nix-command` & `flake` enabled, you can deploy this flake with the following command:

```bash
# deploy my test configuration
sudo nixos-rebuild switch --flake .#nixos-test


# deploy my PC's configuration
rm -rf ~/.config/fcitx5/profile ~/.config/mimeapps.list  # this file may be covered by fcitx5, so remove it first
sudo nixos-rebuild switch --flake .#msi-rtx4090
```

## Other Interesting Dotfiles

Other configurations from where I learned and copied:

- [notwidow/hyprland](https://github.com/notwidow/hyprland): hyprland configuration
- [notusknot/dotfiles-nix](https://github.com/notusknot/dotfiles-nix)
- [xddxdd/nixos-config](https://github.com/xddxdd/nixos-config)
- [bobbbay/dotfiles](https://github.com/bobbbay/dotfiles)
- [gytis-ivaskevicius/nixfiles](https://github.com/gytis-ivaskevicius/nixfiles)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [davidak/nixos-config](https://codeberg.org/davidak/nixos-config)
- [davidtwco/veritas](https://github.com/davidtwco/veritas)
- [NixOS-CN/NixOS-CN-telegram](https://github.com/NixOS-CN/NixOS-CN-telegram)
