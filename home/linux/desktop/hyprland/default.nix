{
  pkgs,
  config,
  lib,
  anyrun,
  ...
} @ args:
with lib; let
  cfg = config.modules.desktop.hyprland;
in {
  imports = [
    anyrun.homeManagerModules.default
  ];

  options.modules.desktop.hyprland = {
    enable = mkEnableOption "hyprland compositor";
  };

  config = mkIf cfg.enable (
    mkMerge
    (map
      (path: import path args)
      [
        ./hyprland.nix
        ./packages.nix
        ./anyrun.nix
        ./wayland-apps.nix
      ])
  );
}
