{
  config,
  pkgs,
  daeuniverse,
  ...
}:
# https://github.com/daeuniverse/flake.nix
let
  daeConfigPath = "/etc/dae/config.dae";
  subscriptionConfigPath = "/etc/dae/config.d/subscription.dae";
in {
  imports = [
    daeuniverse.nixosModules.dae
  ];

  # dae - eBPF-based Linux high-performance transparent proxy.
  services.dae = {
    enable = true;
    package = daeuniverse.packages.${pkgs.system}.dae;
    disableTxChecksumIpGeneric = false;
    configFile = daeConfigPath;
    assets = with pkgs; [v2ray-geoip v2ray-domain-list-community];
    # alternatively, specify assets dir
    # assetsPath = "/etc/dae";
    openFirewall = {
      enable = true;
      port = 12345;
    };
  };

  systemd.services.dae.serviceConfig = {
    Restart = "on-failure";
    RestartSec = 10;
  };

  # dae supports two types of subscriptions: base64 encoded proxies, and sip008.
  # subscription can be a url return the subscription, or a file path that contains the subscription.
  #
  # Nix decrypt and merge my dae's base config and subscription config here.
  # the subscription config is something like:
  #   ```
  #   subscription {
  #     'https://www.example.com/subscription/link'
  #     'https://example.com/no_tag_link'
  #   }
  #   node {
  #     # Support socks5, http, https, ss, ssr, vmess, vless, trojan, trojan-go, tuic, juicity
  #     node_a: 'trojan://'
  #     node_b: 'trojan://'
  #     node_c: 'vless://'
  #     node_d: 'vless://'
  #     node_e: 'vmess://'
  #     node_f: 'tuic://'
  #     node_h: 'juicity://'
  #   }
  #   ```
  system.activationScripts.installDaeConfig = ''
    install -Dm 600 ${./config.dae} ${daeConfigPath}
    install -Dm 600 ${config.age.secrets."dae-subscription.dae".path} ${subscriptionConfigPath}
  '';
}
