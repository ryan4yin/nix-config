# Nix Configuration

This repository is home to the nix code that builds my systems.


## Screenshots

![](./_img/screenshot_2023-05-07-21-21.webp)

## TODO

- [sops-nix](https://github.com/Mic92/sops-nix): secret management
- [devShell](https://github.com/numtide/devshell): manage development environments
- make fcitx5-rime work in vscode/chrome on wayland
- adjust the structure of this repo, make it more flexible, and can easily switch between i3, sway and hyprland.
- migrate my private tools & wireguard configurations into nixos, make it a private flake(private github repo), and used it as flake inputs in this repo.

## Why Nix?

Nix allows for easy to manage, collaborative, reproducible deployments. This means that once something is setup and configured once, it works forever. If someone else shares their configuration, anyone can make use of it.

Want to know Nix in details? Looking for a beginner-friendly tutorial? Check out [NixOS & Nix Flakes - A Guide for Beginners](https://thiscute.world/en/posts/nixos-and-flake-basics/)!

## How to Deploy this Flake?

>Note: you should NOT deploy this flake directly on your machine, it contains my hardware information and personal information which is not suitable for you. You may use this repo as a reference to build your own configuration.

After installed NixOS with `nix-command` & `flake` enabled, you can deploy this flake with the following command:

```bash
# deploy my test configuration
sudo nixos-rebuild switch --flake .#nixos-test


# deploy my PC's configuration
sudo nixos-rebuild switch --flake .#msi-rtx4090
```


## Install Apps from Flatpak

We can install apps from flathub, which has a lot of apps that are not supported well in nixpkgs.

```bash
# Add the Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# install apps from flathub
flatpak install netease-cloud-music-gtk

# or you can search apps from flathub
flatpak search <keyword>
# search on website is also supported: https://flathub.org/
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
