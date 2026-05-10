{
  pkgs,
  pkgs-x64,
  osConfig,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.gaming;
in
{
  options.modules.desktop = {
    gaming = {
      enable = mkEnableOption "Install Game Suite(steam, lutris, etc)";
    };
  };

  config = mkIf cfg.enable {
    # ==========================================================================
    # Other Optimizations
    # Usage:
    #  Lutris - enable advanced options, go to the System options -> Command prefix, add: `mangohud`
    #  Steam  - add this as a launch option: `mangohud %command%` / `gamemoderun %command%`
    # ==========================================================================

    home.packages =
      (with pkgs; [
        # https://github.com/flightlessmango/MangoHud
        # a simple overlay program for monitoring FPS, temperature, CPU and GPU load, and more.
        mangohud

        # GUI for installing custom Proton versions like GE_Proton
        # proton - a Wine distribution aimed at gaming
        protonplus
        # Script to install various redistributable runtime libraries in Wine.
        winetricks
        # https://github.com/Open-Wine-Components/umu-launcher
        # a unified launcher for Windows games on Linux
        umu-launcher

        # Sed-like editor for binary files
        # required by some games to fix problems
        bbe
      ])
      ++ (with pkgs-x64; [
        # Heroic Games Launcher - primarily for Epic Games & GOG
        # https://heroicgameslauncher.com/
        (heroic.override {
          extraPkgs = _pkgs: [
            pkgs.gamescope # aarch64
          ];
        })
      ]);

    # Game launchers for Epic/GOG/Ubisoft/etc. (use Steam + DWProton for common games)

    # a GUI game launcher for Steam/GoG/Epic/Ubisoft
    # https://lutris.net/games?ordering=-popularity
    programs.lutris = {
      enable = true;
      defaultWinePackage = pkgs-x64.proton-ge-bin;
      steamPackage = osConfig.programs.steam.package;
      protonPackages = [ pkgs-x64.proton-ge-bin ];
      winePackages = with pkgs-x64; [
        wineWow64Packages.full
      ];
      extraPackages = with pkgs-x64; [
        winetricks
        gamescope
        gamemode
        mangohud
        umu-launcher
      ];
    };
  };
}
