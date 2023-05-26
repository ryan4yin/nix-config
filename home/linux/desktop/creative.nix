{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    # creative
    # blender   # 3d modeling
    # gimp      # image editing, I prefer using figma in browser instead of this one
    inkscape  # vector graphics
    krita     # digital painting
    kicad     # 3d printing, eletrical engineering
    musescore # music notation
    reaper    # audio production
  ];

  programs = {
    obs-studio.enable = true;
  };
}