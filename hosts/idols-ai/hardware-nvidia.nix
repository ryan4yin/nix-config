{
  config,
  lib,
  pkgs,
  ...
}:
{
  # ===============================================================================================
  # for Nvidia GPU
  # https://wiki.nixos.org/wiki/NVIDIA
  # https://wiki.hyprland.org/Nvidia/
  # ===============================================================================================

  # Hybrid graphics with PRIME[integrated GPU (iGPU) + dedicated GPU (dGPU)]
  hardware.nvidia.prime = {
    # puts dGPU(Nvidia) to sleep and lets the iGPU handle all tasks by default.
    offload.enable = true;

    intelBusId = "PCI:0@0:2:0";
    nvidiaBusId = "PCI:2@0:0:0";
  };

  boot.kernelParams = [
    # Since NVIDIA does not load kernel mode setting by default,
    # enabling it is required to make Wayland compositors function properly.
    "nvidia-drm.fbdev=1"
  ];
  services.xserver.videoDrivers = [ "nvidia" ]; # will install nvidia-vaapi-driver by default

  hardware.nvidia = {
    # Open-source kernel modules are preferred over and planned to steadily replace proprietary modules
    open = true;
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/nvidia-x11/default.nix
    # package = config.boot.kernelPackages.nvidiaPackages.production;

    # https://github.com/NixOS/nixpkgs/issues/489947
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    # required by most wayland compositors!
    modesetting.enable = true;
    powerManagement.enable = true;

    dynamicBoost.enable = lib.mkForce true;
  };

  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics = {
    enable = true;
    # needed by nvidia-docker
    enable32Bit = true;
  };

  services.sunshine.settings = {
    max_bitrate = 20000; # in Kbps
    # NVIDIA NVENC Encoder
    nvenc_preset = 3; # 1(fastest + worst quality) - 7(slowest + best quality)
    nvenc_twopass = "full_res"; # quarter_res / full_res.
  };
}
