{
  config,
  pkgs,
  ...
}:
let
  # prime.offload keeps the Intel iGPU as the default renderer so the dGPU stays
  # free for LLM workloads, so each consumer that should use the RTX 4090 opts
  # into PRIME render offload explicitly. Games need these variables in their
  # Steam launch options: Steam's bubblewrap sandbox does not expose /run, so
  # the nvidia-offload wrapper on PATH is unusable there. WiVRn's server is a
  # headless Vulkan app and needs the same environment; headset-launched games
  # start in separate units or an already running Steam client, so they need
  # the same per-game launch option (see hosts/idols-ai/VR.md).
  dgpuEnv = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };
in
{
  # ===============================================================================================
  # for Nvidia GPU
  # https://wiki.nixos.org/wiki/NVIDIA
  # https://wiki.hyprland.org/Nvidia/
  # ===============================================================================================

  # Hybrid graphics with PRIME[integrated GPU (iGPU) + dedicated GPU (dGPU)]
  hardware.nvidia.prime = {
    # puts dGPU(Nvidia) to sleep and lets the iGPU handle all tasks by default.
    offload = {
      enable = true;
      enableOffloadCmd = true; # generate a nvidia-offload command
    };

    intelBusId = "PCI:0@0:2:0";
    nvidiaBusId = "PCI:2@0:0:0";
  };

  programs.gamescope.env = dgpuEnv;

  # Apply offload to the WiVRn server (see ai/vr.nix). Games need their own
  # offload configuration; this service environment does not propagate to them.
  services.wivrn.monadoEnvironment = dgpuEnv;

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
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # required by most wayland compositors!
    modesetting.enable = true;
    powerManagement.enable = true;
  };

  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics = {
    enable = true;
    # needed by nvidia-docker
    enable32Bit = true;
  };

  # GPU monitoring: CUDA btop (CAP_PERFMON also lets it read the Intel iGPU),
  # nvtop, and the community nvidia_gpu_exporter.
  modules.btop = {
    package = pkgs.btop-cuda;
    perfmon = true;
  };
  environment.systemPackages = [ pkgs.nvtopPackages.full ];
  services.prometheus.exporters.nvidia-gpu.enable = true;

  services.sunshine.settings = {
    adapter_name = "/dev/dri/by-path/pci-0000:00:02.0-render"; # Intel iGPU
    encoder = "vaapi";
  };

  systemd.user.services.sunshine = {
    after = [ "niri.service" ];
    environment.LIBVA_DRIVER_NAME = "iHD";
    preStart = ''
      for _ in {1..20}; do
        if ${config.programs.niri.package}/bin/niri msg outputs | ${pkgs.gnugrep}/bin/grep -q '^Output '; then
          exit 0
        fi
        sleep 0.5
      done

      echo "Sunshine requires at least one Niri output" >&2
      exit 1
    '';
  };
}
