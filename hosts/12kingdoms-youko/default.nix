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

  # The two HDDs behind the flaky USB-SATA bridge, addressed by-id like the
  # disko config does (the /dev/sdX names are not stable).
  hddPublic = "/dev/disk/by-id/ata-WDC_WD40EJRX-89T1XY0_WD-WCC7K0XDCZE6";
  hddEncrypted = "/dev/disk/by-id/ata-WDC_WD40EZRZ-22GXCB0_WD-WCC7K7VV9613";

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

  # Back up the preserved tree through a short-lived read-only snapshot, so the
  # backup is a consistent point-in-time; the module's excludes drop the
  # regenerable bulk and all keys/credentials.
  modules.restic-backup = {
    enable = true;
    repository = "/data/backups/restic/youko";
    snapshotSource = "/btr_pool/@persistent";
    requiresMountsFor = "/data/backups";
    exclude = [
      # regenerable, huge, or unsuitable for file-level backup
      #
      # the whole podman storage tree: the image layers are re-pullable, and its
      # storage DB is not consistent when copied from a running podman.
      # (uptime-kuma uses a named volume under here; its data is not wanted.)
      "var/lib/containers"
      "var/lib/microvms"
      "var/lib/libvirt"
      "nfs"
      "var/cache"
      "var/tmp"
      "var/log"
      "*.qcow2"
    ];
  };

  modules.btrbk.enable = true;

  # The restic REST server the desktops push their backups to. Append-only, so
  # a compromised client still cannot delete history; private repos, so each
  # client only reaches the repository named after its user. Credentials come
  # from agenix; caddy terminates TLS in front of it.
  services.restic.server = {
    enable = true;
    listenAddress = "127.0.0.1:8000";
    dataDir = "/data/backups/rest-server";
    appendOnly = true;
    privateRepos = true;
    "htpasswd-file" = config.age.secrets."restic-rest-htpasswd".path;
  };

  # repositories live on the HDD, which has to be mounted first
  systemd.services.restic-rest-server.unitConfig.RequiresMountsFor = "/data/backups";

  boot.kernelParams = [
    # Use transparent huge pages on demand (madvise) instead of a fixed 1G hugetlb
    # pool (cannot be overcommitted/shared; it stranded memory and blocked
    # scheduling). The VMs now use ordinary memory.
    "transparent_hugepage=madvise"

    # --- mitigations for the flaky USB-SATA bridge the two 4TB HDDs sit behind.
    # It is a JMicron JMS567 that resets and throws link (UDMA-CRC) + I/O errors.
    "usbcore.autosuspend=-1" # no USB autosuspend
    "usb-storage.delay_use=10" # give the bridge time to settle after probing
  ];

  # Keep the bridge powered: a suspended device is what most often triggers a
  # reset on resume.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="152d", ATTR{idProduct}=="0567", TEST=="power/control", ATTR{power/control}="on"
  '';

  # A spindown/spinup is a common trigger for the bridge resetting, so disable
  # APM/standby on the HDDs. sdb in particular has ~1M load cycles (WD
  # Intellipark), so stopping the idle head-parking also saves its mechanism.
  # Read the settings back into the journal, and re-assert them hourly: the
  # bridge or the disk's own firmware can drop them.
  systemd.services.hdd-no-spindown = {
    description = "Disable APM/standby on the USB HDDs";
    after = [ "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for d in ${hddPublic} ${hddEncrypted}; do
        echo "== $d =="
        # -B 255: APM off; -S 0: no standby timer; -J 0: WD idle3 (Intellipark) off
        ${pkgs.hdparm}/bin/hdparm -B 255 -S 0 -J 0 "$d" || true
        ${pkgs.hdparm}/bin/hdparm -B "$d" || true
        ${pkgs.hdparm}/bin/hdparm -J "$d" || true
        ${pkgs.hdparm}/bin/hdparm -C "$d" || true
      done
    '';
  };

  systemd.timers.hdd-no-spindown = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10min";
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
  };

  # Watch the disks with SMART. UDMA_CRC_Error_Count growth is the early warning
  # for the bridge/link problem.
  services.smartd = {
    enable = true;
    notifications.wall.enable = true;
    devices = [
      { device = hddPublic; }
      { device = hddEncrypted; }
    ];
  };
}
