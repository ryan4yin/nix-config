{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.desktop.i3;
in {
  options.modules.desktop.i3 = {
    nvidia = mkEnableOption "whether nvidia GPU is used";
  };

  config = mkIf (cfg.enable && cfg.nvidia) {
    systemd.user.sessionVariables = {
      "LIBVA_DRIVER_NAME" = "nvidia";
      "GBM_BACKEND" = "nvidia-drm";
      "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    };
  };
}
