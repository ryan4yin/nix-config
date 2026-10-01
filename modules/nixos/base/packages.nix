{ pkgs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # system call monitoring
    strace # system call monitoring
    lsof # list open files

    # ebpf related tools
    # https://github.com/bpftrace/bpftrace
    bpftrace # powerful tracing tool

    # system monitoring
    sysstat
    iotop-c
    sysbench
    pv # pipe view

    # system tools
    psmisc # killall/pstree/prtstat/fuser/...
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    dmidecode # a tool that reads information about your system's hardware from the BIOS according to the SMBIOS/DMI standard
    parted
    smartmontools # smartctl -a /dev/nvme0n1
    nvme-cli
  ];

  # BCC - Tools for BPF-based Linux IO analysis, networking, monitoring, and more
  # https://github.com/iovisor/bcc
  programs.bcc.enable = true;
}
