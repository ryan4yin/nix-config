{pkgs, ...}: {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neofetch
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    bpftrace # powerful tracing tool
    tcpdump # network sniffer
    lsof # list open files

    # system monitoring
    sysstat
    iotop
    iftop
    btop
    nmon
    sysbench

    # system tools
    psmisc # killall/pstree/prtstat/fuser/...
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    hdparm # for disk performance, command
    dmidecode # a tool that reads information about your system's hardware from the BIOS according to the SMBIOS/DMI standard
    parted
  ];

  # replace default editor with neovim
  environment.variables.EDITOR = "nvim";
}
