# Desktop Related


3. `base`: all common configurations for all desktops.
4. `hyprland`: Hyprland's configuration.
5. `i3`: i3's configuration.


## Why install I3/Hyprland in Home Manager instead of a NixOS Module?

1. I3 & Hyprland's configuration file is located in `~/.config`, which can be easily managed by Home Manager.
2. There're other user-specific systemd servcies, such gammastep, wallpaper-switcher, etc. which can be easily managed by Home Manager, but if we start i3/hyprland in NixOS Module, they may failed to start automatically. With i3/hyprland installed via home-manager, we can control their systemd service's dependent order, to avoid issues like this.
3. By install as less as possible in NixOS Module, we can:
    1. Make the NixOS system more secure and stable.
    2. Make this flake more portable to other non-NixOS systems, as home-manager can be installed on any Linux system.

