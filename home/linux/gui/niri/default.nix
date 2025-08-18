{
  pkgs,
  config,
  lib,
  ...
}@args:
with lib;
let
  cfg = config.modules.desktop.niri;
in
{
  options.modules.desktop.niri = {
    enable = mkEnableOption "niri compositor";
    settings = lib.mkOption {
      type =
        with lib.types;
        let
          valueType =
            nullOr (oneOf [
              bool
              int
              float
              str
              path
              (attrsOf valueType)
              (listOf valueType)
            ])
            // {
              description = "niri configuration value";
            };
        in
        valueType;
      default = { };
    };
  };

  config = mkIf cfg.enable (mkMerge ([
    {
      programs.wlogout.enable = true;
      programs.alacritty.enable = true; # Super+T in the default setting (terminal)
      programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
      programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
      programs.waybar.enable = true; # launch on startup in the default setting (bar)
      services.mako.enable = true; # notification daemon
      services.swayidle.enable = true; # idle management daemon
      services.polkit-gnome.enable = true; # polkit
      home.packages = with pkgs; [
        swaybg # wallpaper
      ];

      # NOTE: this executable is used by greetd to start a wayland session when system boot up
      # with such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
      home.file.".wayland-session" = {
        source = pkgs.writeScript "init-session" ''
          # trying to stop a previous niri session
          systemctl --user is-active niri.service && systemctl --user stop niri.service
          # and then we start a new one
          /run/current-system/sw/bin/niri-session
        '';
        executable = true;
      };
    }
  ]
  # ++ (import ./values args)
  ));
}
