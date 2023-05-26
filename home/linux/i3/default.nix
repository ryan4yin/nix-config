{
  pkgs,
  config,
  lib,
  ...
}: {
  # i3 配置，基于 https://github.com/endeavouros-team/endeavouros-i3wm-setup
  # 直接从当前文件夹中读取配置文件作为配置内容

  imports = [
    ./x11-apps.nix
  ];

  # wallpaper, binary file
  home.file.".config/i3/wallpaper.png".source = ../wallpapers/wallpaper.png;
  home.file.".config/i3/config".source = ./config;
  home.file.".config/i3/i3blocks.conf".source = ./i3blocks.conf;
  home.file.".config/i3/keybindings".source = ./keybindings;
  home.file.".config/i3/scripts" = {
    source = ./scripts;
    # copy the scripts directory recursively
    recursive = true;
    executable = true;  # make all scripts executable
  };

  # rofi is a application launcher and dmenu replacement
  home.file.".config/rofi" = {
    source = ./rofi-conf;
    # copy the scripts directory recursively
    recursive = true;
  };

  # allow fontconfig to discover fonts and configurations installed through home.packages
  fonts.fontconfig.enable = true;

  systemd.user.sessionVariables = {
    "LIBVA_DRIVER_NAME" = "nvidia";
    "GBM_BACKEND" = "nvidia-drm";
    "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
  };

  # set dpi for 4k monitor
  xresources.properties = {
    # dpi for Xorg's font
    "Xft.dpi" = 162;
    # or set a generic dpi
    "*.dpi" = 162;
  };

  # set Xcursor.theme & Xcursor.size in ~/.Xresources automatically
  home.pointerCursor = {
    name = "Qogir-dark";
    package = pkgs.qogir-theme;
    size = 64;
  };
}