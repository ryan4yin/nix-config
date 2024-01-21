{
  lib,
  polybar-themes,
  ...
}: {
  # NOTE:
  # We have to enable hyprland/i3's systemd user service in home-manager,
  # so that gammastep/wallpaper-switcher's user service can be start correctly!
  # they are all depending on hyprland/i3's user graphical-session
  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      config = lib.mkForce null; # ignores all home-manager's default i3 config
      extraConfig = builtins.readFile ../conf/i3-config;
    };
    # Path, relative to HOME, where Home Manager should write the X session script.
    # and NixOS will use it to start xorg session when system boot up
    scriptPath = ".xsession";
  };

  xdg.configFile = {
    "i3/scripts" = {
      source = ../conf/scripts;
      # copy the scripts directory recursively
      recursive = true;
      executable = true; # make all scripts executable
    };
  };

  home.file = {
    ".config/polybar" = {
      source = ../conf/polybar;
      recursive = true;
      executable = true;
    };
    ".local/share/fonts" = {
      source = "${polybar-themes}/fonts";
      recursive = true;
    };

    ".local/bin" = {
      source = ../bin;
      recursive = true;
      executable = true;
    };

    # xrandr - set primary screen
    ".screenlayout/monitor.sh".source = ../conf/dual-monitor-4k-1080p.sh;
  };
}
