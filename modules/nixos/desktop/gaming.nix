{
  pkgs,
  nix-gaming,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.gaming;
in
{
  imports = [
    nix-gaming.nixosModules.pipewireLowLatency
    nix-gaming.nixosModules.platformOptimizations
  ];

  options.modules.desktop = {
    gaming = {
      enable = mkEnableOption "Install Game Suite(steam, lutris, etc)";
    };
  };

  config = mkIf cfg.enable {
    # ==========================================================================
    # Gaming on Linux
    #
    #   <https://www.protondb.com/> can give you an idea what works where and how.
    #   Begineer Guide: <https://www.reddit.com/r/linux_gaming/wiki/faq/>
    # ==========================================================================

    # Games installed by Steam works fine on NixOS, no other configuration needed.
    # https://github.com/NixOS/nixpkgs/blob/master/doc/packages/steam.section.md
    programs.steam = {
      # Some location that should be persistent:
      #   ~/.local/share/Steam - The default Steam install location
      #   ~/.local/share/Steam/steamapps/common - The default Game install location
      #   ~/.steam/root        - A symlink to ~/.local/share/Steam
      #   ~/.steam             - Some Symlinks & user info
      enable = true;
      package = pkgs.steam;
      # https://github.com/Winetricks/winetricks
      # Whether to enable protontricks, a simple wrapper for running Winetricks commands for Proton-enabled games.
      protontricks.enable = true;
      # Whether to enable Load the extest library into Steam, to translate X11 input events to uinput events (e.g. for using Steam Input on Wayland) .
      extest.enable = true;
      fontPackages = [
        pkgs.wqy_zenhei # Need by steam for Chinese
      ];
      # DW-Proton (Dawn Winery's Proton fork) carries the anti-cheat and game
      # patches that mainline Proton/GE-Proton lack, so it is what runs the anime
      # gacha games (Wuthering Waves, Honkai: Star Rail, Arknights: Endfield, ...);
      # GE-Proton is the general fallback. Both appear as compatibility tools in
      # each game's Properties -> Compatibility.
      # https://dawn.wine/dawn-winery/dwproton
      extraCompatPackages = [
        pkgs.dwproton-bin
        pkgs.proton-ge-bin
      ];
    };

    # GameScope: run a game in its own nested compositor and let it renice
    # itself for steadier frame pacing. GPU-specific PRIME render offload belongs
    # to the host, not here (see programs.gamescope.env in
    # hosts/idols-ai/hardware-nvidia.nix).
    # https://github.com/ValveSoftware/gamescope
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    # see https://github.com/fufexan/nix-gaming/#pipewire-low-latency
    services.pipewire.lowLatency.enable = true;
    programs.steam.platformOptimizations.enable = true;

    # Optimise Linux system performance on demand
    # https://github.com/FeralInteractive/GameMode
    # https://wiki.archlinux.org/title/Gamemode
    #
    # Usage:
    #   1. For games/launchers which integrate GameMode support:
    #      https://github.com/FeralInteractive/GameMode#apps-with-gamemode-integration
    #      simply running the game will automatically activate GameMode.
    programs.gamemode.enable = true;
  };
}
