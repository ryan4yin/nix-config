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
    #  Steam - add this as a launch option: `mangohud %command%`. GameMode does not reach
    #  sandboxed games (see hardening/README.md), so `gamemoderun` is not available there.
    # ==========================================================================

    home.packages = with pkgs; [
      # https://github.com/flightlessmango/MangoHud
      # a simple overlay program for monitoring FPS, temperature, CPU and GPU load, and more.
      mangohud

      # https://github.com/Open-Wine-Components/umu-launcher
      # a unified launcher for Windows games on Linux, sandboxed with
      # ~/Gaming as its home and only writable host directory. umu-run, winetricks,
      # bbe and mangohud live inside it; the nix-config-umu-game skill and
      # the launchers it generates run through `umu-sandbox`.
      nixpaks.umu

      # Steam and Heroic share the same sandbox policy and the same ~/Gaming
      # home, so their libraries, prefixes and Proton builds stay inside it.
      # Steam runs its own pressure-vessel container inside the sandbox; see
      # modules/nixos/desktop/gaming.nix for what replacing programs.steam costs.
      nixpaks.steam
      # Heroic Games Launcher - primarily for Epic Games & GOG
      # https://heroicgameslauncher.com/
      nixpaks.heroic
    ];
  };
}
