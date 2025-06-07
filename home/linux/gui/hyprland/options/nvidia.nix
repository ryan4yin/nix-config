{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.desktop.hyprland;
in {
  options.modules.desktop.hyprland = {
    nvidia = mkEnableOption "whether nvidia GPU is used";
  };

  config = mkIf (cfg.enable && cfg.nvidia) {
    wayland.windowManager.hyprland.settings.env = [
      # for hyprland with nvidia gpu, ref https://wiki.hyprland.org/Nvidia/
      "LIBVA_DRIVER_NAME,nvidia"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      # enable native Wayland support for most Electron apps
      "ELECTRON_OZONE_PLATFORM_HINT,auto"
      # VA-API hardware video acceleration
      "NVD_BACKEND,direct"

      "GBM_BACKEND,nvidia-drm"
    ];
  };
}
