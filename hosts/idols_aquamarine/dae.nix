{
  pkgs,
  daeuniverse,
}:
# https://github.com/daeuniverse/flake.nix
{
  imports = [
    daeuniverse.nixosModules.dae
    daeuniverse.nixosModules.daed
  ];

  # dae - eBPF-based Linux high-performance transparent proxy.
  services.dae = {
    enable = true;
    package = pkgs.dae;
    disableTxChecksumIpGeneric = false;
    configFile = ./bypass-router.dae;
    assets = with pkgs; [v2ray-geoip v2ray-domain-list-community];
    # alternatively, specify assets dir
    # assetsPath = "/etc/dae";
    openFirewall = {
      enable = true;
      port = 12345;
    };
  };

  # daed, a modern web dashboard for dae.
  services.daed = {
    enable = true;
    package = pkgs.daed;
    configdir = "/etc/daed";
    listen = "0.0.0.0:9090";
    openfirewall = {
      enable = true;
      port = 9090;
    };
  };
}
