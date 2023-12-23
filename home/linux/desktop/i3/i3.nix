_: {
  # i3 window manager's config, based on https://github.com/endeavouros-team/endeavouros-i3wm-setup

  # NOTE:
  # We have to enable hyprland/i3's systemd user service in home-manager,
  # so that gammastep/wallpaper-switcher's user service can be start correctly!
  # they are all depending on hyprland/i3's user graphical-session
  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      extraConfig = builtins.readFile ./i3-config;
    };
    # Path, relative to HOME, where Home Manager should write the X session script.
    # and NixOS will use it to start xorg session when system boot up
    scriptPath = ".xsession";
  };

  xdg.configFile = {
    "i3/i3blocks.conf".source = ./i3blocks.conf;
    "i3/scripts" = {
      source = ./scripts;
      # copy the scripts directory recursively
      recursive = true;
      executable = true; # make all scripts executable
    };
    "i3/layouts" = {
      source = ./layouts;
      recursive = true;
    };
    # rofi is a application launcher and dmenu replacement
    "rofi" = {
      source = ./rofi-conf;
      # copy the scripts directory recursively
      recursive = true;
    };
  };

  home.file = {
    ".local/bin/bright" = {
      source = ./bin/bright;
      executable = true;
    };
    ".local/bin/logout" = {
      source = ./bin/logout;
      executable = true;
    };

    # xrandr - set primary screen
    ".screenlayout/monitor.sh".source = ./dual-monitor-4k-1080p.sh;
  };

  # allow fontconfig to discover fonts and configurations installed through home.packages
  fonts.fontconfig.enable = true;

  systemd.user.sessionVariables = {
    "LIBVA_DRIVER_NAME" = "nvidia";
    "GBM_BACKEND" = "nvidia-drm";
    "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
  };
}
