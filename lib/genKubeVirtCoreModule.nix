{
  pkgs,
  hostName,
  networking,
  ...
}: let
  inherit (networking.hostsAddr.${hostName}) iface;
in {
  # supported file systems, so we can mount any removable disks with these filesystems
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    #"zfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
    "nfs" # required by longhorn
    "cifs" # mount windows share
  ];

  boot.kernelModules = ["kvm-amd" "vfio-pci"];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # for amd cpu

  environment.systemPackages = with pkgs; [
    # Validate Hardware Virtualization Support via:
    #   virt-host-validate qemu
    libvirt

    # used by kubernetes' ovs-cni plugin
    # https://github.com/k8snetworkplumbingwg/multus-cni
    multus-cni
  ];

  # Workaround for longhorn running on NixOS
  # https://github.com/longhorn/longhorn/issues/2166
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  # Longhorn uses open-iscsi to create block devices.
  services.openiscsi = {
    name = "iqn.2020-08.org.linux-iscsi.initiatorhost:${hostName}";
    enable = true;
  };

  # Enable the Open vSwitch as a systemd service
  # It's required by kubernetes' ovs-cni plugin.
  virtualisation.vswitch = {
    enable = true;
    # reset the Open vSwitch configuration database to a default configuration on every start of the systemd ovsdb.service
    resetOnStart = false;
  };
  networking.vswitches = {
    # https://github.com/k8snetworkplumbingwg/ovs-cni/blob/main/docs/demo.md
    ovsbr1 = {
      # Attach the interfaces to OVS bridge
      # This interface should not used by the host itself!
      interfaces.${iface} = {};
    };
  };
  networking = {
    inherit hostName;
    inherit (networking) defaultGateway nameservers;

    networkmanager.enable = false;
    # Set the host's address on the OVS bridge interface instead of the physical interface!
    interfaces.ovsbr1 = networking.hostsInterface.${hostName}.interfaces.${iface};
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
