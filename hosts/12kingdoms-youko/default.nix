{
  config,
  pkgs,
  mylib,
  myvars,
  disko,
  ...
}:
let
  hostName = "youko"; # Define your hostname.

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

  boot.kernelParams = [
    # Use transparent huge pages on demand (madvise) instead of a fixed 1G hugetlb
    # pool (cannot be overcommitted/shared; it stranded memory and blocked
    # scheduling). The VMs now use ordinary memory.
    "transparent_hugepage=madvise"

    # --- mitigations for the flaky USB-SATA bridge the two 4TB HDDs sit behind.
    # It is a JMicron JMS567 that resets and throws link (UDMA-CRC) + I/O errors.
    "usbcore.autosuspend=-1" # no USB autosuspend
    "usb-storage.delay_use=10" # give the bridge time to settle after probing
    "pcie_aspm=off" # ASPM can also make the link flap
  ];

  # Keep the bridge powered: a suspended device is what most often triggers a
  # reset on resume.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="152d", ATTR{idProduct}=="0567", TEST=="power/control", ATTR{power/control}="on"
  '';

  # A spindown/spinup is a common trigger for the bridge resetting, so disable
  # APM/standby on the HDDs. Best effort: hdparm may not get through the bridge.
  systemd.services.hdd-no-spindown = {
    description = "Disable APM/standby on the USB HDDs";
    after = [
      "dev-sda.device"
      "dev-sdb.device"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.hdparm}/bin/hdparm -B 255 -S 0 /dev/sda || true
      ${pkgs.hdparm}/bin/hdparm -B 255 -S 0 /dev/sdb || true
    '';
  };

  # Watch the disks with SMART. UDMA_CRC_Error_Count growth is the early warning
  # for the bridge/link problem.
  services.smartd = {
    enable = true;
    notifications.wall.enable = true;
    devices = [
      { device = "/dev/sda"; }
      { device = "/dev/sdb"; }
    ];
  };
}
