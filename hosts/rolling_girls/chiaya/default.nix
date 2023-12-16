{
  config,
  username,
  # nixos-jh7110,
  ...
} @ args:
#############################################################
#
#  Chiaya - NixOS Configuration for Milk-V Mars
#
#  WIP, not working yet.
#
#############################################################
{
  imports = [
    {
      # cross-compilation this flake.
      nixpkgs.crossSystem = {
        system = "riscv64-linux";
      };
    }

    # TODO

    ../../../modules/nixos/core-riscv64.nix
    ../../../modules/nixos/user-group.nix
  ];

  users.users.root.openssh.authorizedKeys.keys = config.users.users."${username}".openssh.authorizedKeys.keys;

  # Set static IP address / gateway / DNS servers.
  networking = {
    hostName = "chiaya"; # Define your hostname.
    wireless.enable = false;

    # Failed to enable firewall due to the following error:
    #   firewall-start[2300]: iptables: Failed to initialize nft: Protocol not supported
    firewall.enable = false;

    defaultGateway = "192.168.5.201";
    nameservers = [
      "119.29.29.29" # DNSPod
      "223.5.5.5" # AliDNS
    ];

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # milkv-mars RJ45 port
    interfaces.end0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.5.106";
          prefixLength = 24;
        }
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
