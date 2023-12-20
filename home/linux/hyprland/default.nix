{
  lib,
  pkgs,
  hyprland,
  nur-ryan4yin,
  ...
}: {
  imports = [
    ./anyrun.nix
    ./wayland-apps.nix
  ];

  # NOTE:
  #   (Required) NixOS Module: enables critical components needed to run Hyprland properly
  #   (Optional) Home-manager module: lets you declaratively configure Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.system}.hyprland;
    settings = lib.mkForce {};
    extraConfig = builtins.readFile ./hypr-conf/hyprland.conf;
    # programs.grammastep need this to be enabled.
    systemd.enable = true;
  };

  # hyprland configs, based on https://github.com/notwidow/hyprland
  xdg.configFile."hypr/mako" = {
    source = ./hypr-conf/mako;
    recursive = true;
  };
  xdg.configFile."hypr/scripts" = {
    source = ./hypr-conf/scripts;
    recursive = true;
  };
  xdg.configFile."hypr/waybar" = {
    source = ./hypr-conf/waybar;
    recursive = true;
  };
  xdg.configFile."hypr/wlogout" = {
    source = ./hypr-conf/wlogout;
    recursive = true;
  };
  xdg.configFile."hypr/themes" = {
    source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-hyprland}/themes";
    recursive = true;
  };

  # music player - mpd
  xdg.configFile."mpd" = {
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
}
