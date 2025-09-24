{
  myvars,
  mylib,
  ...
}:
#############################################################
#
#  Ruby - a NixOS VM running on Proxmox/KubeVirt
#
#############################################################
let
  hostName = "ruby"; # Define your hostname.

  inherit (myvars.networking) proxyGateway proxyGateway6 nameservers;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";
in {
  imports = mylib.scanPaths ./.;

  # Enable binfmt emulation of aarch64-linux, this is required for cross compilation.
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];
  # This enables the kernel to preload the emulator binaries when the binfmt registrations are added,
  # obviating the need to make the emulator binaries available inside chroots and chroot-like sandboxes.
  boot.binfmt.preferStaticEmulators = true; # required to work with podman

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
  ];

  boot.kernelModules = ["kvm-amd"];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # for amd cpu

  networking = {
    inherit hostName;

    # we use networkd instead
    networkmanager.enable = false;
    useDHCP = false;
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network.networks."10-${iface}" = {
    matchConfig.Name = [iface];
    networkConfig = {
      Address = [ipv4WithMask];
      DNS = nameservers;
      DHCP = "ipv6"; # enable DHCPv6 only, so we can get a GUA.
      IPv6AcceptRA = true; # for Stateless IPv6 Autoconfiguraton (SLAAC)
      LinkLocalAddressing = "ipv6";
    };
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = proxyGateway;
      }
      {
        Destination = "::/0";
        Gateway = proxyGateway6;
        GatewayOnLink = true; # it's a gateway on local link.
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
