# Desktop Related

3. `base`: all common configurations for all desktops.
4. `hyprland`: Hyprland's configuration.
5. `i3`: i3's configuration.

## Why install I3/Hyprland in Home Manager instead of a NixOS Module?

1. I3 & Hyprland's configuration file is located in `~/.config`, which can be easily managed by Home
   Manager.
2. I have many user-specific systemd services, such gammastep, wallpaper-switcher, etc. Which can be
   easily managed by Home Manager, but if we add i3/hyprland in a NixOS Module, those user-level
   services may failed to start automatically. With i3/hyprland in a Home Manager Module, we can
   control their systemd service's dependent order more easily, so we can avoid issues like this.
3. By install packages as less as possible in NixOS Module, we can:
   1. Make the NixOS system more secure and stable.
   2. Make this flake more portable to other non-NixOS systems, as home-manager can be installed on
      any Linux system.
