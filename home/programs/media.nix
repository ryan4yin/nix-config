{
  pkgs,
  config,
  ...
}:
# media - control and enjoy audio/video
{
  # imports = [
  # ];

  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
    pulsemixer

    ffmpeg-full

    # images
    viu  # terminal image viewer
    imv  # simple image viewer
    imagemagick
    deepin.image-editor
  ];

  programs = {
    mpv = {
      enable = true;
      defaultProfiles = ["gpu-hq"];
      scripts = [pkgs.mpvScripts.mpris];
    };

    obs-studio.enable = true;
  };

  services = {
    playerctld.enable = true;
  };
}