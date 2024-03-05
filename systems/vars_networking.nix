{lib, ...}: rec {
  mainGateway = "192.168.5.1"; # main router
  defaultGateway = "192.168.5.101"; # subrouter with a transparent proxy
  nameservers = [
    "119.29.29.29" # DNSPod
    "223.5.5.5" # AliDNS
  ];
  prefixLength = 24;

  hostAddress =
    lib.attrsets.mapAttrs
    (name: address: {inherit prefixLength address;})
    {
      "ai" = "192.168.5.100";
      "aquamarine" = "192.168.5.101";
      "ruby" = "192.168.5.102";
      "kana" = "192.168.5.103";
      "nozomi" = "192.168.5.104";
      "yukina" = "192.168.5.105";
      "chiaya" = "192.168.5.106";
      "suzu" = "192.168.5.107";
      "k3s-prod-1-master-1" = "192.168.5.108";
      "k3s-prod-1-master-2" = "192.168.5.109";
      "k3s-prod-1-master-3" = "192.168.5.110";
      "k3s-prod-1-worker-1" = "192.168.5.111";
      "k3s-prod-1-worker-2" = "192.168.5.112";
      "k3s-prod-1-worker-3" = "192.168.5.113";
      "kubevirt-shoryu" = "192.168.5.176";
      "kubevirt-shushou" = "192.168.5.177";
      "kubevirt-youko" = "192.168.5.178";
      "rakushun" = "192.168.5.179";
      "tailscale-gw" = "192.168.5.192";
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
        aquamarine.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHJrHY3BZRTu0hrlsKxqS+O4GDp4cbumF8aNnbPCGKji root@aquamarine";
        ruby.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAMmGni8imcaS40cXgLbVQqPYnDYKs8MSbyWL91RV98 root@ruby";
        kana.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcINkxU3KxPsCpWltfEBjDYtKEeCmgrDxyUadl1iZ1D root@kana";
      };
  };
}
