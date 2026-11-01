{
  pkgs,
  lib,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # creative
      nixpaks.krita # digital painting
      nixpaks.musescore # music notation
      nixpaks.orca-slicer # 3d printer slicer app
      nixpaks.bambu-studio # bambu 3d printer slicer app
      nixpaks.blender # 3d modeling
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
      nixpaks.obs-studio # screen recording and streaming; plugins are bundled by the wrapper
    ];
}
