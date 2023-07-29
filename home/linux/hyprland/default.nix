{pkgs, catppuccin-hyprland, ...}: {
  imports = [
    ./wayland-apps.nix
  ];

  # Only available on home-manager's master branch(2023/7/25)
  # wayland.windowManager.hyprland = {
  #   enable = true;
  # };

  # hyprland configs, based on https://github.com/notwidow/hyprland
  home.file.".config/hypr" = {
    source = ./hypr-conf;
    # copy the scripts directory recursively
    recursive = true;
  };
  home.file.".config/hypr-themes".source = "${catppuccin-hyprland}/themes";

  home.file.".config/hypr/wallpapers/wallpaper.png".source = ../wallpapers/wallpaper.png;

  # gtk's theme settings, generate files: 
  #   1. ~/.gtkrc-2.0
  #   2. ~/.config/gtk-3.0/settings.ini
  #   3. ~/.config/gtk-4.0/settings.ini
  gtk = {
    enable = true;
    theme = {
      # https://github.com/catppuccin/gtk
      name = "Catppuccin-Macchiato-Compact-Pink-dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" "black" ];
        variant = "macchiato";
      };
    };
  };

  # music player - mpd
  home.file.".config/mpd" = {
    source = ./mpd;
    recursive = true;
  };

  # allow fontconfig to discover fonts and configurations installed through home.packages
  fonts.fontconfig.enable = true;

  systemd.user.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # for any ozone-based browser & electron apps to run on wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # for firefox to run on wayland
    "MOZ_WEBRENDER" = "1";

    # for hyprland with nvidia gpu, ref https://wiki.hyprland.org/Nvidia/
    "LIBVA_DRIVER_NAME" = "nvidia";
    "XDG_SESSION_TYPE" = "wayland";
    "GBM_BACKEND" = "nvidia-drm";
    "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    "WLR_NO_HARDWARE_CURSORS" = "1";
    "WLR_EGL_NO_MODIFIRES" = "1";
  };

  # this is for xwayland
  # set dpi for 4k monitor
  xresources.properties = {
    "Xft.dpi" = 162;
  };

  # set Xcursor.theme & Xcursor.size in ~/.Xresources automatically
  home.pointerCursor = {
    name = "Qogir-dark";
    package = pkgs.qogir-theme;
    size = 64;
  };
}
