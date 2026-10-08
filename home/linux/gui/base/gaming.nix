{
  pkgs,
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
      enable = mkEnableOption "Enable desktop gaming support";
    };
  };

  config = mkIf cfg.enable {
    # ==========================================================================
    # Other Optimizations
    # Usage:
    #  UMU game launchers use MangoHud by default; set ENABLE_MANGOHUD=0 in their conf to disable.
    #  Steam - add this as a launch option: `mangohud %command%` / `gamemoderun %command%`
    # ==========================================================================

    home.packages =
      (with pkgs; [
        # https://github.com/flightlessmango/MangoHud
        # a simple overlay program for monitoring FPS, temperature, CPU and GPU load, and more.
        mangohud

        # Script to install various redistributable runtime libraries in Wine.
        winetricks
        # https://github.com/Open-Wine-Components/umu-launcher
        # a unified launcher for Windows games on Linux
        umu-launcher

        # Sed-like editor for binary files
        # required by some games to fix problems
        bbe
      ])
      ++ (with pkgs; [
        # Heroic Games Launcher - primarily for Epic Games & GOG
        # https://heroicgameslauncher.com/
        (heroic.override {
          extraPkgs = _pkgs: [
            pkgs.gamescope
          ];
        })
      ]);

  };
}
