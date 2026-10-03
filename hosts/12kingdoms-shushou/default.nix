{
  config,
  pkgs,
  mylib,
  myvars,
  disko,
  ...
}:
let
  hostName = "shushou"; # Define your hostname.

  coreModule = mylib.genVmHostModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
in
{
  imports = (mylib.scanPaths ./.) ++ [
    disko.nixosModules.default
    ../k8s/disko-config/host-disko-fs.nix
    ../12kingdoms-shoryu/hardware-configuration.nix
    ../12kingdoms-shoryu/preservation.nix
    coreModule
  ];

  modules.btrbk.enable = true;

  # MinisForum UM560: Radeon iGPU. The ROCm build of btop shows the GPU panel;
  # node_exporter's drm collector exposes its utilization/VRAM.
  modules.btop.package = pkgs.btop-rocm;
  services.prometheus.exporters.node.enabledCollectors = [ "drm" ];
}
