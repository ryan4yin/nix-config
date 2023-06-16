{ pkgs
, config
, ...
}:
# processing audio/video
{
  home.packages = with pkgs; [
    ffmpeg-full

    # images
    viu # terminal image viewer
    imagemagick
    graphviz
  ];
}
