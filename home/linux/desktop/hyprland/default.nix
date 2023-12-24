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
    ./options
  ];

  options.modules.desktop.hyprland = {
    enable = mkEnableOption "hyprland compositor";
    settings = lib.mkOption {
      type = with lib.types; let
        valueType =
          nullOr (oneOf [
            bool
            int
            float
            str
            path
            (attrsOf valueType)
            (listOf valueType)
          ])
          // {
            description = "Hyprland configuration value";
          };
      in
        valueType;
      default = {};
    };
  };

  config = mkIf cfg.enable (
    mkMerge ([
        {
          wayland.windowManager.hyprland.settings = cfg.settings;
        }
      ]
      ++ (import ./values args))
  );
}
