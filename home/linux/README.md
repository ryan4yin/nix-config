# Home Manager's Linux Submodules

1. `base`: The base module that is suitable for any NixOS environment.
2. `desktop`: Configuration for desktop environments, such as Hyprland, I3, etc.
3. `server.nix`: Configuration which is suitable for both servers and desktops. It import only
   `base` as its submodule.
   1. used by all my nixos servers.
4. `desktop.nix`: the entrypoint of desktop's configuration, it import both `base` and `desktop` as
   its submodules.
   1. used by all my nixos desktops.
