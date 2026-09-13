{
  pkgs,
  pkgs-x64,
  ...
}:
# media - control and enjoy audio/video
{
  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
    pulsemixer
    imv # simple image viewer

    # video/audio tools
    libva-utils
    vdpauinfo
    vulkan-tools
    mesa-demos
    nvitop
    # Zoom: Settings > Share Screen > Advanced > Screen Capture Mode on Wayland > PipeWire Mode.
    (pkgs-x64.zoom-us)
  ];

  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    scripts = [ pkgs.mpvScripts.mpris ];
  };

  services = {
    playerctld.enable = true;

    # PipeWire audio effects daemon for output loudness normalization (e.g.
    # bilibili videos with inconsistent volume).
    #
    # The chain is declared here instead of configured in the GUI: autogain
    # normalizes loudness, limiter is a transparent safety net against peaks.
    # EasyEffects follows the system default output device by default
    # (`useDefaultOutputDevice`), so no GUI state needs to be persisted.
    easyeffects = {
      enable = true;

      extraPresets.loudness-normalization.output = {
        blocklist = [ ];
        "plugins_order" = [
          "autogain#0"
          "limiter#0"
        ];
        "autogain#0" = {
          bypass = false;
          # target is set per host (home/hosts/linux/*.nix) because the
          # comfortable loudness depends on the physical output device:
          # -23 dB (EBU R128 broadcast standard) on desktop speakers,
          # -12 dB on quiet laptop speakers. EasyEffects' own default is -23.
        };
        "limiter#0" = {
          bypass = false;
          # Pure brick-wall safety net: leave 1 dB of ceiling margin and add no
          # makeup gain, so autogain stays in charge of loudness.
          threshold = -1.0;
          gain-boost = false;
        };
      };

      # Load the preset on the output pipeline when the daemon starts.
      preset.output = "loudness-normalization";
    };
  };
}
