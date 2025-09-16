{ pkgs, osConfig, ... }:
{
  # ==========================================================================
  # Other Optimizations
  # Usage:
  #  Lutris - enable advanced options, go to the System options -> Command prefix, add: `mangohud`
  #  Steam  - add this as a launch option: `mangohud %command%` / `gamemoderun %command%`
  # ==========================================================================

  home.packages = with pkgs; [
    # https://github.com/flightlessmango/MangoHud
    # a simple overlay program for monitoring FPS, temperature, CPU and GPU load, and more.
    mangohud
    # a game launcher - great for epic games and gog games
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
      ];
    })
    # GUI for installing custom Proton versions like GE_Proton
    # proton - a Wine distribution aimed at gaming
    protonplus
    # Script to install various redistributable runtime libraries in Wine.
    winetricks
    # https://github.com/Open-Wine-Components/umu-launcher
    # a unified launcher for Windows games on Linux
    umu-launcher
  ];

  # a GUI game launcher for Steam/GoG/Epic
  programs.lutris = {
    enable = true;
    defaultWinePackage = pkgs.proton-ge-bin;
    steamPackage = osConfig.programs.steam.package;
    protonPackages = [ pkgs.proton-ge-bin ];
    winePackages = with pkgs; [
      wineWow64Packages.full
      wineWowPackages.stagingFull
    ];
    extraPackages = with pkgs; [
      winetricks
      gamescope
      gamemode
      mangohud
      umu-launcher
    ];
  };
}
