{
  lib,
  config,
  pkgs,
  wallpapers,
  ...
}:

let
  package = pkgs.noctalia-shell;
in
{

  home.packages = [
    package
    pkgs.qt6Packages.qt6ct # for icon theme
    pkgs.app2unit # Launch Desktop Entries (or arbitrary commands) as Systemd user units
  ]
  ++ (lib.optionals pkgs.stdenv.isx86_64 [
    pkgs.gpu-screen-recorder # recoding screen
  ]);

  home.file."Pictures/Wallpapers".source = wallpapers;

  xdg.configFile =
    let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
      confPath = "${config.home.homeDirectory}/nix-config/home/linux/gui/base/noctalia";
    in
    {
      # NOTE: use config dir as noctalia config because config is not only settings.json
      # https://github.com/noctalia-dev/noctalia-shell/blob/main/nix/home-module.nix#L211-L220
      "noctalia".source = mkSymlink "${confPath}/config";
      "qt6ct/qt6ct.conf".source = mkSymlink "${confPath}/qt6ct.conf";
    };

  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia Shell - Wayland desktop shell";
      Documentation = "https://docs.noctalia.dev/docs";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
    };

    Service = {
      ExecStart = lib.getExe package;
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
