{
  pkgs,
  config,
  ...
}: {
  # hyprland configs, based on https://github.com/notwidow/hyprland
  home.file.".config/hypr" = {
    source = ./hypr-conf;
    # copy the scripts directory recursively
    recursive = true;
  };
  home.file.".config/gtk-3.0" = {
    source = ./gtk-3.0;
    recursive = true;
  };
  home.file.".gtkrc-2.0".source = ./gtkrc-2.0;
  home.file.".config/hypr/wallpapers/wallpaper.png".source = ../wallpapers/wallpaper.png;
  home.file.".config/fcitx5" = {
    source = ./fcitx5;
    recursive = true;
  };

  # allow fontconfig to discover fonts and configurations installed through home.packages
  fonts.fontconfig.enable = true;

  systemd.user.sessionVariables = {
    "NIXOS_OZONE_WL" = "1";  # for any ozone-based browser & electron apps to run on wayland
    "MOZ_ENABLE_WAYLAND" = "1";  # for firefox to run on wayland
    "MOZ_WEBRENDER" = "1";

    # for hyprland with nvidia gpu, ref https://wiki.hyprland.org/Nvidia/
    "LIBVA_DRIVER_NAME" = "nvidia";
    "XDG_SESSION_TYPE" = "wayland";
    "GBM_BACKEND" = "nvidia-drm";
    "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    "WLR_NO_HARDWARE_CURSORS" = "1";
    "WLR_EGL_NO_MODIFIRES" = "1";

    # copy from  https://github.com/nix-community/home-manager/blob/master/modules/i18n/input-method/fcitx5.nix
    GLFW_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx";
    IMSETTINGS_MODULE  = "fcitx";
  };
}

