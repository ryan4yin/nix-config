{pkgs, ...}: {
  ##########################################################################################################
  #
  #  NixOS's Configuration for Wayland based Window Manager
  #
  #    hyprland: project starts from 2022, support Wayland, envolving fast, good looking, support Nvidia GPU.
  #
  ##########################################################################################################

  imports = [
    ./base/i18n.nix
    ./base/misc.nix
    ./base/networking.nix
    ./base/remote-building.nix
    ./base/user-group.nix
    ./base/visualisation.nix

    ./desktop
    ../base.nix
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
    ];
  };

  services = {
    xserver.enable = false;
    # https://wiki.archlinux.org/title/Greetd
    greetd = {
      enable = true;
      settings = {
        default_session = {
           user = "ryan";  # Hyprland is installed only for user ryan via home-manager!
           command = "Hyprland";  # start Hyprland directly without a login manager
           # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";  # start Hyprland with a TUI login manager
        };
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    waybar # the status bar
    swaybg # the wallpaper
    swayidle # the idle timeout
    swaylock # locking the screen
    wlogout # logout menu
    wl-clipboard # copying and pasting
    hyprpicker # color picker

    wf-recorder # creen recording
    grim # taking screenshots
    slurp # selecting a region to screenshot
    # TODO replace by `flameshot gui --raw | wl-copy`

    mako # the notification daemon, the same as dunst

    yad # a fork of zenity, for creating dialogs

    # audio
    alsa-utils # provides amixer/alsamixer/...
    mpd # for playing system sounds
    mpc-cli # command-line mpd client
    ncmpcpp # a mpd client with a UI
    networkmanagerapplet # provide GUI app: nm-connection-editor
  ];

  # fix https://github.com/ryan4yin/nix-config/issues/10
  security.pam.services.swaylock = {};
}
