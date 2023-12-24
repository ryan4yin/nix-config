{
  pkgs,
  lib,
  hyprland,
  nur-ryan4yin,
  ...
}: {
  # NOTE:
  # We have to enable hyprland/i3's systemd user service in home-manager,
  # so that gammastep/wallpaper-switcher's user service can be start correctly!
  # they are all depending on hyprland/i3's user graphical-session
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.system}.hyprland;
    settings = {};
    extraConfig = builtins.readFile ./hypr-conf/hyprland.conf;
    # gammastep/wallpaper-switcher need this to be enabled.
    systemd.enable = true;
  };

  # NOTE: this executable is used by greetd to start a wayland session when system boot up
  # with such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
  home.file.".wayland-session" = {
    source = "${pkgs.hyprland}/bin/Hyprland";
    executable = true;
  };

  # hyprland configs, based on https://github.com/notwidow/hyprland
  xdg.configFile = {
    "hypr/mako" = {
      source = ./hypr-conf/mako;
      recursive = true;
    };
    "hypr/scripts" = {
      source = ./hypr-conf/scripts;
      recursive = true;
    };
    "hypr/waybar" = {
      source = ./hypr-conf/waybar;
      recursive = true;
    };
    "hypr/wlogout" = {
      source = ./hypr-conf/wlogout;
      recursive = true;
    };
    "hypr/themes" = {
      source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-hyprland}/themes";
      recursive = true;
    };

    # music player - mpd
    "mpd" = {
      source = ./mpd;
      recursive = true;
    };
  };

  # allow fontconfig to discover fonts and configurations installed through home.packages
  fonts.fontconfig.enable = true;

  systemd.user.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # for any ozone-based browser & electron apps to run on wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # for firefox to run on wayland
    "MOZ_WEBRENDER" = "1";
  };
}
