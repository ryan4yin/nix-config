{
  pkgs,
  pkgs-x64,
  pkgs-unstable,
  nur-ryan4yin,
  ...
}:
# media - control and enjoy audio/video
{
  home.packages =
    with pkgs;
    [
      # audio control
      pavucontrol
      playerctl
      pulsemixer
      imv # simple image viewer

      # video/audio tools
      libva-utils
      vdpauinfo
      vulkan-tools
      glxinfo
      nvitop
      (pkgs-x64.zoom-us.override { hyprlandXdgDesktopPortalSupport = true; })
    ];

  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    scripts = [ pkgs.mpvScripts.mpris ];
  };

  services = {
    playerctld.enable = true;
  };
}
