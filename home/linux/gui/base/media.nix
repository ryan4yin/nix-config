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
    # PipeWire audio effects daemon, used for loudness normalization (e.g. bilibili
    # videos with inconsistent volume). Configure plugins (autogain + limiter) once
    # in the GUI; the daemon then auto-applies the preset at login.
    easyeffects.enable = true;
  };
}
