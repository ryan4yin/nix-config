{
  config,
  pkgs,
  wallpapers,
  dms,
  ...
}:
{
  imports = [
    dms.homeModules.dankMaterialShell.default
  ];

  home.packages = [
    pkgs.qt6Packages.qt6ct # for icon theme
  ];

  home.file."Pictures/Wallpapers".source = wallpapers;

  xdg.configFile =
    let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
      confPath = "${config.home.homeDirectory}/nix-config/home/linux/gui/base/dma-shell";
    in
    {
      "DankMaterialShell/settings.json".source = mkSymlink "${confPath}/settings.json";
      "qt6ct/qt6ct.conf".source = mkSymlink "${confPath}/qt6ct.conf";
    };

  systemd.user.services.dms.Service.Environment = [
    "QT_QPA_PLATFORM=wayland"
    "QT_QPA_PLATFORMTHEME=qt6ct"
  ];

  programs.dankMaterialShell = {
    enable = true;

    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dankMaterialShell changes
    };

    # Core features
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableClipboard = true; # Clipboard history manager
    enableVPN = true; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
  };
}
