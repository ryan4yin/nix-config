{
  lib,
  config,
  pkgs,
  wallpapers,
  ...
}:

{

  home.packages =
    with pkgs;
    [
      noctalia-shell
      qt6Packages.qt6ct # for icon theme
      app2unit # Launch Desktop Entries (or arbitrary commands) as Systemd user units
    ]
    ++ (lib.optionals pkgs.stdenv.isx86_64 [
      gpu-screen-recorder # recoding screen
    ]);

  home.file."Pictures/Wallpapers".source = wallpapers;

  xdg.configFile =
    let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
      confPath = "${config.home.homeDirectory}/nix-config/home/linux/gui/base/noctalia";
    in
    {
      "noctalia/settings.json".source = mkSymlink "${confPath}/settings.json";
    };

  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia Shell - Wayland desktop shell";
      Documentation = "https://docs.noctalia.dev/docs";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
    };

    Service = {
      ExecStart = lib.getExe pkgs.noctalia-shell;
      Restart = "on-failure";

      Environment = [
        "QT_QPA_PLATFORM=wayland;xcb"
        "QT_QPA_PLATFORMTHEME=qt6ct"
        "QT_AUTO_SCREEN_SCALE_FACTOR=1"
      ];
    };

    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
