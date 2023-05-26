{pkgs, ...}:


{
  # i3wm: old and stable, only support X11
  # sway: compatible with i3wm, support Wayland. do not support Nvidia GPU officially.
  # hyprland: project starts from 2022, support Wayland, envolving fast, good looking, support Nvidia GPU.

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "hyprland";
      lightdm.enable = false;
      gdm = {
        enable = true;
        wayland = true;
      };
    };
  };

  programs.hyprland = {
    enable = true;

    xwayland = {
      enable = true;
      hidpi = true;
    };

    nvidiaPatches = true;
  };
  programs.light.enable = true;     # monitor backlight control


  # thunar file manager(part of xfce) related options
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    waybar        # the status bar
    swaybg        # the wallpaper
    swayidle      # the idle timeout
    swaylock      # locking the screen
    wlogout       # logout menu
    wl-clipboard  # copying and pasting

    wf-recorder   # creen recording
    grim      # taking screenshots
    slurp     # selecting a region to screenshot
    # TODO replace by `flameshot gui --raw | wl-copy`

    wofi      # A rofi inspired launcher for wlroots compositors such as sway/hyprland
    mako      # the notification daemon, the same as dunst

    yad      # a fork of zenity, for creating dialogs

    # 用于播放系统音效
    mpd      # for playing system sounds
    mpc-cli  # command-line mpd client
    ncmpcpp  # a mpd client with a UI
    networkmanagerapplet  # provide GUI app: nm-connection-editor 

    xfce.thunar  # xfce4's file manager
  ];
}
