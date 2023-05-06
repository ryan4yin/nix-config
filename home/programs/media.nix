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
    graphviz

    # creative
    blender   # 3d modeling
    gimp      # image editing
    inkscape  # vector graphics
    krita     # digital painting

    # 3d printing, eletrical engineering
    kicad
    
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