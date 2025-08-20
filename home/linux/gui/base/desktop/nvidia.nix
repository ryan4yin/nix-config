{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.nvidia;
in
{
  options.modules.desktop.nvidia = {
    enable = mkEnableOption "whether nvidia GPU is used";
  };

  config = mkIf (cfg.enable && cfg.enable) {
    home.sessionVariables = {
      # for hyprland with nvidia gpu" = " ref https://wiki.hyprland.org/Nvidia/
      "LIBVA_DRIVER_NAME" = "nvidia";
      "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
      # VA-API hardware video acceleration
      "NVD_BACKEND" = "direct";

      "GBM_BACKEND" = "nvidia-drm";
    };
  };
}
