{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config.modules) hardwareTools debugTools;
in
{
  options.modules.hardwareTools.enable =
    lib.mkEnableOption ''
      Basic hardware and disk introspection tools (lm_sensors, pciutils,
      usbutils, dmidecode, parted, smartmontools, nvme-cli).

      On by default for physical hosts; MicroVM guests turn it off since they
      share the host's store and cannot use any of it.
    ''
    // {
      default = true;
    };

  options.modules.debugTools.enable = lib.mkEnableOption ''
    Tracing and benchmarking tools (strace, bpftrace, sysstat, iotop-c,
    sysbench and the BCC tools).

    Off by default: opt in on hosts where you actually profile with them
    (currently idols-ai).
  '';

  config = {
    environment.systemPackages =
      with pkgs;
      [
        # broadly useful on every host
        lsof # list open files
        psmisc # killall/pstree/prtstat/fuser/...
        ethtool
        pv # pipe view
      ]
      ++ lib.optionals hardwareTools.enable [
        lm_sensors # `sensors` command
        pciutils # lspci
        usbutils # lsusb
        dmidecode # SMBIOS/DMI hardware info (from the BIOS)
        parted
        smartmontools # smartctl -a /dev/nvme0n1
        nvme-cli
      ]
      ++ lib.optionals debugTools.enable [
        strace # system call tracing
        bpftrace # eBPF tracing, https://github.com/bpftrace/bpftrace
        sysstat
        iotop-c
        sysbench
      ];

    # BCC - tools for BPF-based IO/network analysis/monitoring
    # https://github.com/iovisor/bcc
    programs.bcc.enable = debugTools.enable;
  };
}
