{
  nixos-licheepi4a,
  myvars,
  ...
}:
#############################################################
#
#  Yukina - NixOS configuration for Lichee Pi 4A
#
#############################################################
let
  hostName = "yukina"; # Define your hostname.
in {
  imports = [
    # import the licheepi4a module, which contains the configuration for bootloader/kernel/firmware
    (nixos-licheepi4a + "/modules/licheepi4a.nix")
    # import the sd-image module, which contains the fileSystems & kernel parameters for booting from sd card.
    (nixos-licheepi4a + "/modules/sd-image/sd-image-lp4a.nix")
  ];

  # Set static IP address / gateway / DNS servers.
  networking = {
    inherit hostName;
    inherit (myvars.networking) defaultGateway nameservers;
    inherit (myvars.networking.hostsInterface.${hostName}) interfaces;

    wireless = {
      # https://wiki.archlinux.org/title/wpa_supplicant
      enable = true;
      # The path to the file containing the WPA passphrase.
      # secrets are not supported well on riscv64, I nned to create this file manually.
      # Format: "PSK_WEMEET_PRIVATE_WIFI=your_password"
      environmentFile = "/etc/wpa_supplicant.env";
      # The network definitions to automatically connect to when wpa_supplicant is running.
      networks = {
        # read WPAPSK from environmentFile
        "shadow_light_ryan".psk = "@PSK_WEMEET_PRIVATE_WIFI@";
      };
    };

    # Failed to enable firewall due to the following error:
    #   firewall-start[2300]: iptables: Failed to initialize nft: Protocol not supported
    firewall.enable = false;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # LPI4A's first ethernet interface
    # interfaces.end0 = {
    #   useDHCP = false;
    #   ipv4.addresses = [
    #     {
    #       address = "192.168.5.104";
    #       prefixLength = 24;
    #     }
    #   ];
    # };
    # LPI4A's second ethernet interface
    # interfaces.end1 = {
    #   useDHCP = false;
    #   ipv4.addresses = [
    #     {
    #       address = "192.168.xx.xx";
    #       prefixLength = 24;
    #     }
    #   ];
    # };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
