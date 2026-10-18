{
  config,
  pkgs,
  ...
}:
{
  # ===============================================================================================
  # for Nvidia GPU
  # https://wiki.nixos.org/wiki/NVIDIA
  # https://wiki.hyprland.org/Nvidia/
  #
  # The RTX 4090 is the only GPU on this host: the i5-13600KF has no iGPU, so
  # there is no PRIME offload to configure and nothing to keep the dGPU "free"
  # for.
  # ===============================================================================================

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

  # Bound the driver's free-buffer pool for niri only: it never returns freed
  # vidmem, so niri's VRAM grows past 1 GiB (WA-039). Applies at niri's next start.
  # https://github.com/niri-wm/niri/wiki/Nvidia#high-vram-usage-fix
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
    builtins.toJSON {
      rules = [
        {
          pattern = {
            feature = "procname";
            matches = "niri";
          };
          profile = "Limit Free Buffer Pool On Wayland Compositors";
        }
      ];
      profiles = [
        {
          name = "Limit Free Buffer Pool On Wayland Compositors";
          settings = [
            {
              key = "GLVidHeapReuseRatio";
              value = 0;
            }
          ];
        }
      ];
    };

  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics = {
    enable = true;
    # needed by nvidia-docker
    enable32Bit = true;
  };

  # GPU monitoring: CUDA btop, nvtop, and the community nvidia_gpu_exporter.
  modules.btop.package = pkgs.btop-cuda;
  environment.systemPackages = [ pkgs.nvtopPackages.full ];
  services.prometheus.exporters.nvidia-gpu.enable = true;

  services.sunshine.settings = {
    max_bitrate = 20000; # in Kbps
    # No adapter_name: Sunshine picks the only adapter, the 4090.
    nvenc_preset = 3;
    nvenc_twopass = "full_res";
  };

  systemd.user.services.sunshine = {
    after = [ "niri.service" ];
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
