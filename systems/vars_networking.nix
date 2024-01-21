{lib, ...}: rec {
  defaultGateway = "192.168.5.201";
  nameservers = [
    "119.29.29.29" # DNSPod
    "223.5.5.5" # AliDNS
  ];
  prefixLength = 24;

  hostAddress = {
    "ai" = {
      inherit prefixLength;
      address = "192.168.5.100";
    };
    "aquamarine" = {
      inherit prefixLength;
      address = "192.168.5.101";
    };
    "ruby" = {
      inherit prefixLength;
      address = "192.168.5.102";
    };
    "kana" = {
      inherit prefixLength;
      address = "192.168.5.103";
    };
    "nozomi" = {
      inherit prefixLength;
      address = "192.168.5.104";
    };
    "yukina" = {
      inherit prefixLength;
      address = "192.168.5.105";
    };
    "chiaya" = {
      inherit prefixLength;
      address = "192.168.5.106";
    };
    "suzu" = {
      inherit prefixLength;
      address = "192.168.5.107";
    };
    "tailscale_gw" = {
      inherit prefixLength;
      address = "192.168.5.192";
    };
  };

  ssh = {
    # define the host alias for remote builders
    # this config will be written to /etc/ssh/ssh_config
    # ''
    #   Host ruby
    #     HostName 192.168.5.102
    #     Port 22
    #
    #   Host kana
    #     HostName 192.168.5.103
    #     Port 22
    #   ...
    # '';
    extraConfig =
      lib.attrsets.foldlAttrs
      (acc: host: value:
        acc
        + ''
          Host ${host}
            HostName ${value.address}
            Port 22
        '')
      ""
      hostAddress;

    # define the host key for remote builders so that nix can verify all the remote builders
    # this config will be written to /etc/ssh/ssh_known_hosts
    knownHosts =
      # Update only the values of the given attribute set.
      #
      #   mapAttrs
      #   (name: value: ("bar-" + value))
      #   { x = "a"; y = "b"; }
      #     => { x = "bar-a"; y = "bar-b"; }
      lib.attrsets.mapAttrs
      (host: value: {
        hostNames = [host hostAddress.${host}.address];
        publicKey = value.publicKey;
      })
      {
        aquamarine.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0EzzjnuHBE9xEOZupLmaAj9xbYxkUDeLbMqFZ7YPjU";
        ruby.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHrDXNQXELnbevZ1rImfXwmQHkRcd3TDNLsQo33c2tUf";
        kana.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMVX05DQD1XJ0AqFZzsRsqgeUOlZ4opAI+8tkVXyjq+";
      };
  };
}
