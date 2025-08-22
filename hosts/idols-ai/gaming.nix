{ pkgs, nix-gaming, ... }:
{
  # https://wiki.archlinux.org/title/steam
  # Games installed by Steam works fine on NixOS, no other configuration needed.
  programs.steam = {
    # Some location that should be persistent:
    #   ~/.local/share/Steam - The default Steam install location
    #   ~/.local/share/Steam/steamapps/common - The default Game install location
    #   ~/.steam/root        - A symlink to ~/.local/share/Steam
    #   ~/.steam             - Some Symlinks & user info
    enable = pkgs.stdenv.isx86_64;
    # https://github.com/ValveSoftware/gamescope
    # Run a GameScope driven Steam session from your display-manager
    # fix resolution upscaling and stretched aspect ratios
    gamescopeSession.enable = true;
    # https://github.com/Winetricks/winetricks
    # Whether to enable protontricks, a simple wrapper for running Winetricks commands for Proton-enabled games.
    protontricks.enable = true;
    # Whether to enable Load the extest library into Steam, to translate X11 input events to uinput events (e.g. for using Steam Input on Wayland) .
    extest.enable = true;
    fontPackages = [
      pkgs.wqy_zenhei # Need by steam for Chinese
    ];
  };

  # see https://github.com/fufexan/nix-gaming/#pipewire-low-latency
  services.pipewire.lowLatency.enable = true;
  programs.steam.platformOptimizations.enable = true;
  imports = with nix-gaming.nixosModules; [
    pipewireLowLatency
    platformOptimizations
  ];

  # ==========================================================================
  # Other Optimizations
  # Usage:
  #  Lutris - enable advanced options, go to the System options -> Command prefix, add: `mangohud`
  #  Steam  - add this as a launch option: `mangohud %command%` / `gamemoderun %command%`
  # ==========================================================================

  environment.systemPackages = with pkgs; [
    # https://github.com/flightlessmango/MangoHud
    # a simple overlay program for monitoring FPS, temperature, CPU and GPU load, and more.
    mangohud
    # a GUI game launcher for Steam/GoG/Epic
    lutris
  ];

  # Optimise Linux system performance on demand
  # https://github.com/FeralInteractive/GameMode
  # https://wiki.archlinux.org/title/Gamemode
  #
  # Usage:
  #   1. For games/launchers which integrate GameMode support:
  #      https://github.com/FeralInteractive/GameMode#apps-with-gamemode-integration
  #      simply running the game will automatically activate GameMode.
  programs.gamemode.enable = pkgs.stdenv.isx86_64;
}
