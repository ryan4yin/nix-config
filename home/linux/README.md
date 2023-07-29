# Home Manager's Linux Submodules

1. `base`: The base module that is suitable for any NixOS environment.
2. `desktop`: Configuration for desktop environments, such as Hyprland, I3, etc.
3. `fcitx5`: fcitx5's configuration(Chinese input method).
4. `hyprland`: Hyprland's configuration.
5. `i3`: i3's configuration.
6. `server.nix`: Configuration which is suitable for both servers and desktops. It import only `base` as its submodule.
    1. used by all my nixos servers.
6. `desktop-hyprland.nix`: the entrypoint of hyprland's configuration, it import all the submodules above, except `i3`.
    1. used by my hyprland desktop.
7. `desktop-i3.nix`: the entrypoint of i3's configuration, it import all the submodules above, except `hyprland`.
    1. used by my i3 desktop.
