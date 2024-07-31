{
  pkgs,
  config,
  wallpapers,
  ...
}: let
  hostCommonConfig = ''
    encode zstd gzip
    tls ${../../certs/ecc-server.crt} ${config.age.secrets."certs/ecc-server.key".path} {
      protocols tls1.3 tls1.3
      curves x25519 secp384r1 secp521r1
    }
  '';
in {
  services.caddy = {
    enable = true;
    # Reload Caddy instead of restarting it when configuration file changes.
    enableReload = true;
    user = "caddy"; # User account under which caddy runs.
    dataDir = "/var/lib/caddy";
    logDir = "/var/log/caddy";

    # Additional lines of configuration appended to the global config section of the Caddyfile.
    # Refer to https://caddyserver.com/docs/caddyfile/options#global-options for details on supported values.
    globalConfig = ''
      http_port    80
      https_port   443
      auto_https   disable_certs
    '';

    # Dashboard
    virtualHosts."home.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      reverse_proxy http://localhost:4401
    '';

    # https://caddyserver.com/docs/caddyfile/directives/file_server
    virtualHosts."file.writefor.fun".extraConfig = ''
      root * /var/lib/caddy/fileserver/
      ${hostCommonConfig}
      file_server browse {
        hide .git
        precompressed zstd br gzip
      }
    '';

    virtualHosts."git.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3301
    '';
    virtualHosts."sftpgo.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3302
    '';
    virtualHosts."webdav.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3303
    '';
    virtualHosts."transmission.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:9091
    '';

    # Monitoring
    virtualHosts."uptime-kuma.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3350
    '';
    virtualHosts."grafana.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3351
    '';
    virtualHosts."prometheus.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:9090
    '';
    virtualHosts."alertmanager.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:9093
    '';
  };
  networking.firewall.allowedTCPPorts = [80 443];

  # Create Directories
  systemd.tmpfiles.rules = [
    "d /var/lib/caddy/fileserver/ 0755 caddy caddy"
    # directory for virtual machine's images
    "d /var/lib/caddy/fileserver/vms 0755 caddy caddy"
  ];

  # Add all my wallpapers into /var/lib/caddy/fileserver/wallpapers
  # Install the homepage-dashboard configuration files
  system.activationScripts.installCaddyWallpapers = ''
    mkdir -p /var/lib/caddy/fileserver/wallpapers
    ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F644 ${wallpapers}/ /var/lib/caddy/fileserver/wallpapers/
  '';
}
