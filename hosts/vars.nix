{
  networking = rec {
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
      "tailscale-gw" = {
        inherit prefixLength;
        address = "192.168.5.192";
      };
    };
  };
}
