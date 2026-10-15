{
  pkgs,
  myvars,
  ...
}:
{
  # ===============================================================================================
  # 2x AMD Radeon AI PRO R9700 (RDNA4, gfx1201) for local inference
  # https://wiki.nixos.org/wiki/AMD_GPU
  #
  # The second full-length x16 slot is chipset-attached: its root port is Gen4 x4
  # while the card side reports x16, so the second card reads weights at ~7.1 GB/s
  # against 46.3 GB/s. Split models by layer, not tensor parallel — see ./README.md
  # and ./ROCM.md (ROCm support, measured links, RCCL TP=2 deadlock).
  # ===============================================================================================

  boot.kernelModules = [ "amdgpu" ];

  boot.kernelParams = [
    # ROCm: multi-GPU systems may hang in compute applications unless the IOMMU
    # runs in passthrough mode.
    # https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html
    "iommu=pt"

    # This board's DSDT advertises ATPX power control (`\_SB.PC00.GFX0.ATPX`) but
    # never defines the `PEG0.PEGP._OFF`/`_ON` symbols its body calls, so the first
    # idle resume of the headless card leaves it in `runtime_status = error` until
    # reboot; amdgpu discards the ACPI error, so the failure is silent. This is the
    # only setting that avoids it, and it needs the iGPU kept for the console
    # fallback to trigger at all. Root cause, kernel-source trail and the field
    # comparison: ./ROCM.md (WA-032).
    "amdgpu.runpm=0"

    # The driver's own default is -1, "auto, disabled except SRIOV", so on bare
    # metal a hung card stays hung until the next reboot. Nobody is here to
    # power-cycle an unattended inference host, so switch the recovery path on.
    "amdgpu.gpu_recovery=1"

    # ASPM L0s/L1 on a link that carries PCIe traffic for a compute card buys
    # little and is a known source of link retraining and timeouts; this repo
    # already falls back to the same knob for NVMe APST problems (WA-008).
    "pcie_aspm=off"

    # Keep the CPU out of the deepest C-states. Inference waits on short PCIe and
    # memory round-trips, and the exit latency from C6/C7 shows up as decode
    # jitter. Costs idle power: drop this line if that matters more than tail
    # latency.
    "processor.max_cstate=2"
  ];

  # amdgpu firmware.
  hardware.enableRedistributableFirmware = true;

  hardware.graphics = {
    enable = true;
  };

  # The ROCm OpenCL ICD, which is also what HIP consumers resolve for compute.
  hardware.amdgpu.opencl.enable = true;

  # /dev/kfd is world-writable under nixpkgs' default udev rule, but
  # /dev/dri/renderD* is `render` 0660 and this headless host has no logged-in
  # seat to hand out ACLs, so the inference user needs the group.
  users.users.${myvars.username}.extraGroups = [ "render" ];

  environment.systemPackages = [
    pkgs.rocmPackages.rocm-smi
    pkgs.rocmPackages.rocminfo
    pkgs.nvtopPackages.full
  ];

  # Cap both cards at 220 W. amdgpu exposes the cap through hwmon in microwatts and accepts any
  # value inside [power1_cap_min, power1_cap_max] — 210-300 W on these cards. The set path
  # (amdgpu_dpm_set_power_limit) has no overdrive gate, so ppfeaturemask keeps its default.
  # https://github.com/ryan4yin/nix-config/issues/449
  systemd.services.amdgpu-power-cap = {
    description = "Cap the power limit of every amdgpu card at 220 W";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      path = [ pkgs.coreutils ];
      ExecStart = pkgs.writeShellScript "amdgpu-power-cap" ''
        cap=220000000 # microwatts
        want=2 # both R9700s; this host has no other amdgpu device
        # The cards probe asynchronously, so retry briefly instead of racing the driver.
        for _ in $(seq 1 60); do
          capped=0
          for hwmon in /sys/class/hwmon/hwmon*; do
            [ "$(cat "$hwmon/name" 2>/dev/null)" = amdgpu ] || continue
            # The subshell keeps a rejected write from printing one shell error per retry; the
            # summary below is the line an operator needs.
            if (echo "$cap" > "$hwmon/power1_cap") 2>/dev/null &&
              [ "$(cat "$hwmon/power1_cap" 2>/dev/null)" = "$cap" ]; then
              capped=$((capped + 1))
            fi
          done
          if [ "$capped" -ge "$want" ]; then
            echo "capped $capped amdgpu cards at 220 W"
            exit 0
          fi
          sleep 1
        done
        echo "amdgpu power cap: only $capped of $want cards took the cap" >&2
        exit 1
      '';
    };
  };

  # GPU panel in btop, and utilization/VRAM in node_exporter for the shared
  # VictoriaMetrics scrape — the same shape as the Radeon iGPU hosts.
  # perfmon: CAP_PERFMON is what btop needs for the i915 iGPU.
  modules.btop = {
    package = pkgs.btop-rocm;
    perfmon = true;
  };
  # `enabledCollectors` is a list option, so this merges with the base module's
  # `[ "systemd" "logind" ]` instead of replacing it: only name the collector
  # this host adds. Repeating the base entries passes `--collector.systemd`
  # twice, which node_exporter rejects, and the unit restart-loops.
  services.prometheus.exporters.node.enabledCollectors = [ "drm" ];
}
