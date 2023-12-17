{pkgs, ...}: {
  ####################################################################
  #
  #  NixOS's Configuration for I3 Window Manager
  #
  ####################################################################

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

  # i3 related options
  services = {
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images

    xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true;
        autoLogin = {
          enable = true;
          user = "ryan";
        };
        defaultSession = "none+i3";
      };
      # Configure keymap in X11
      xkb.layout = "us";

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          rofi # application launcher, the same as dmenu
          dunst # notification daemon
          i3blocks # status bar
          i3lock # default i3 screen locker
          xautolock # lock screen after some time
          i3status # provide information to i3bar
          i3-gaps # i3 with gaps
          picom # transparency and shadows
          feh # set wallpaper
          xcolor # color picker

          acpi # battery information
          arandr # screen layout manager
          dex # autostart applications
          xbindkeys # bind keys to commands
          xorg.xbacklight # control screen brightness, the same as light
          xorg.xdpyinfo # get screen information
          scrot # minimal screen capture tool, used by i3 blur lock to take a screenshot
          sysstat # get system information
          alsa-utils # provides amixer/alsamixer/...
        ];
      };
    };
  };
}
