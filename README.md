# Nix Configuration

This repository is home to the nix code that builds my systems.


## TODO

- vscode extensions
- secret management

## How to install Nix and Deploy this Flake?

Nix can be used on Linux and MacOS, we have to method to install Nix:

1. [Official Way to Install Nix](https://nixos.org/download.html): writen in bash script, `nix-command` & `flake` are disabled by default till now (2023-04-23).
   1. you need to follow [Enable flakes - NixOS Wiki](https://nixos.wiki/wiki/Flakes) to enable `flake` feature.
   2. and it provide no method to uninstall nix automatically, you need to delte all resources & users & group(`nixbld`) manually.
2. [The Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer): writen mainly in Rust, enable `nix-command` & `flake` by default, and offer an easy way to uninstall Nix.

After installed Nix with `nix-command` & `flake` enabled, you can deploy this flake with the following command:

```bash
sudo nixos-rebuild switch .#nixos
```

## Why Nix?

Nix allows for easy to manage, collaborative, reproducible deployments. This means that once something is setup and configured once, it works forever. If someone else shares their configuration, anyone can make use of it.


## References

- [Nix Flake Basics](./Nix_Flake_Basics.md)
