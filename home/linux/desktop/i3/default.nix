{
  pkgs,
  config,
  lib,
  ...
} @ args:
with lib; let
  cfg = config.modules.desktop.i3;
in {
  imports = [
    ./nvidia.nix
  ];

  options.modules.desktop.i3 = {
    enable = mkEnableOption "i3 window manager";
  };

  config = mkIf cfg.enable (
    mkMerge
    (map
      (path: import path args)
      [
        ./i3.nix
        ./packages.nix
        ./x11-apps.nix
      ])
  );
}
