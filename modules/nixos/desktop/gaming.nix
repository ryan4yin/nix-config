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
      enable = mkEnableOption "desktop gaming support";
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

    # Expose DW-Proton to umu-run: umu ignores Steam's
    # STEAM_EXTRA_COMPAT_TOOLS_PATHS, and a store path baked into a generated
    # launcher goes stale on every dwproton-bin update. The nix-config-umu-game
    # skill and the run/exec scripts it generates read this first.
    environment.variables.UMU_PROTONPATH = "${pkgs.dwproton-bin.steamcompattool}";

    # GameScope: run a game in its own nested compositor and let it renice
    # itself for steadier frame pacing. GPU-specific PRIME render offload belongs
    # to the host, not here (see programs.gamescope.env in
    # hosts/idols-ai/hardware-nvidia.nix).
    # https://github.com/ValveSoftware/gamescope
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    # The sysctls SteamOS ships in steamos-customizations-jupiter (file names
    # below), as carried by nix-gaming's platformOptimizations module.
    boot.kernel.sysctl = {
      # 20-shed.conf
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      # 20-net-timeout.conf: lets a game that was killed and restarted quickly
      # rebind its TCP ports.
      "net.ipv4.tcp_fin_timeout" = 5;
      # 30-splitlock.conf: no deliberate slowdown when a game hits a split lock.
      "kernel.split_lock_mitigate" = 0;
      # 30-vm.conf: MAX_INT - MAPCOUNT_ELF_CORE_MARGIN, see include/linux/mm.h.
      "vm.max_map_count" = 2147483642;
    };

    # Low-latency PipeWire: a 64/48000 minimum quantum plus realtime scheduling,
    # as in nix-gaming's pipewireLowLatency module.
    services.pipewire.extraConfig = {
      pipewire."99-lowlatency" = {
        "context.properties"."default.clock.min-quantum" = 64;
        "context.modules" = [
          {
            name = "libpipewire-module-rt";
            flags = [
              "ifexists"
              "nofail"
            ];
            args = {
              "nice.level" = -15;
              "rt.prio" = 88;
              "rt.time.soft" = 200000;
              "rt.time.hard" = 200000;
            };
          }
        ];
      };
      pipewire-pulse."99-lowlatency"."pulse.properties" = {
        "server.address" = [ "unix:native" ];
        "pulse.min.req" = "64/48000";
        "pulse.min.quantum" = "64/48000";
        "pulse.min.frag" = "64/48000";
      };
      client."99-lowlatency"."stream.properties" = {
        "node.latency" = "64/48000";
        "resample.quality" = 1;
      };
    };

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
