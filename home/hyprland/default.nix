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
  home.file.".config/hypr/wallpapers/lockscreen.png".source = ../wallpapers/lockscreen.png;
  home.file.".config/hypr/wallpapers/wallpaper.png".source = ../wallpapers/wallpaper.png;

  # allow fontconfig to discover fonts and configurations installed through home.packages
  fonts.fontconfig.enable = true;

	home.packages =
    let
      icomoon-feather-font = pkgs.callPackage ./icomoon-feather-font.nix { };
    in
    with pkgs; [
      icomoon-feather-font

    waybar        # for the status bar
    swaybg        # for setting the wallpaper
    swayidle      # for setting the idle timeout
    swaylock      # for locking the screen
    wl-clipboard  # for copying and pasting

    wf-recorder   # for screen recording
    grim      # for taking screenshots
    slurp     # for selecting a region to screenshot
    # TODO replace by `flameshot gui --raw | wl-copy`

    xfce.xfce4-appfinder  # for the application launcher

    wofi      # for the application launcher
    mako      # for the notification daemon

    light    # for changing the screen brightness
    yad      # for the brightness popup

    # 用于播放系统音效
    mpd      # for playing system sounds
    mpc-cli  # command-line mpd client
    ncmpcpp  # a mpd client with a UI
	];

  # if use vscode in wayland, uncomment those line
  systemd.user.sessionVariables = {
    "NIXOS_OZONE_WL" = "1";   # for vscode
    "MOZ_ENABLE_WAYLAND" = "1";

    # for hyprland with nvidia gpu, ref https://wiki.hyprland.org/Nvidia/
    "LIBVA_DRIVER_NAME" = "nvidia";
    "XDG_SESSION_TYPE" = "wayland";
    "GBM_BACKEND" = "nvidia-drm";
    "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    "WLR_NO_HARDWARE_CURSORS" = "1";
  };
}