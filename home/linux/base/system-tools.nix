{ pkgs, config, ... }:


{
  # Linux Only Packages, not available on Darwin
  home.packages = with pkgs; [
    btop # replacement of htop/nmon
    htop
    iotop
    nmon

    ## networking tools
    wireguard-tools # manage wireguard vpn manually, via wg-quick
    iftop

    # misc
    libnotify

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    hdparm # for disk performance, command 
    dmidecode # a tool that reads information about your system's hardware from the BIOS according to the SMBIOS/DMI standard

    cifs-utils # for mounting windows shares
  ];

  # auto mount usb drives
  services = {
    udiskie.enable = true;
  };

  services = {
    # syncthing.enable = true;
  };

}
