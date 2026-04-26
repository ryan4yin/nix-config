{
  pkgs,
  modulesPath,
  ...
}:
{

  imports = [
    (modulesPath + "/hardware/cpu/intel-npu.nix")
  ];

  # Intel NPU support
  hardware.cpu.intel.npu.enable = true;

  # kvm virtualization support
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModprobeConfig = "options kvm_intel nested=1";
  boot.extraModulePackages = [ ];

  # Intel Graphics
  # https://wiki.nixos.org/wiki/Intel_Graphics

  services.xserver.videoDrivers = [ "modesetting" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # Required for modern Intel GPUs (Xe iGPU and ARC)
      intel-media-driver # VA-API (iHD) userspace
      vpl-gpu-rt # oneVPL (QSV) runtime

      # Optional (compute / tooling):
      intel-compute-runtime # OpenCL (NEO) + Level Zero for Arc/Xe
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Prefer the modern iHD backend
  };

  # May help if FFmpeg/VAAPI/QSV init fails (esp. on Arc with i915):
  hardware.enableRedistributableFirmware = true;
  boot.kernelParams = [ "i915.enable_guc=3" ];

  # May help services that have trouble accessing /dev/dri (e.g., jellyfin/plex):
  # users.users.<service>.extraGroups = [ "video" "render" ];
}
