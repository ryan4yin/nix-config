{ mylib, pkgs, ... }:
{
  # wayland related
  home.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # for any ozone-based browser & electron apps to run on wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # for firefox to run on wayland
    "MOZ_WEBRENDER" = "1";
    # enable native Wayland support for most Electron apps
    "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
    # misc
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
    "QT_QPA_PLATFORM" = "wayland";
    "SDL_VIDEODRIVER" = "wayland";
    "GDK_BACKEND" = "wayland";
    "XDG_SESSION_TYPE" = "wayland";
  };

  home.packages = with pkgs; [
    swaybg # the wallpaper
    wl-clipboard # copying and pasting
    hyprpicker # color picker
    brightnessctl
    # audio
    alsa-utils # provides amixer/alsamixer/...
    networkmanagerapplet # provide GUI app: nm-connection-editor
    # screenshot/screencast
    flameshot
    hyprshot # screen shot
    wf-recorder # screen recording
  ];

  # screen locker
  programs.swaylock.enable = true;

  # Logout Menu
  programs.wlogout.enable = true;
}
