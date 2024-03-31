{myvars, ...}: {
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
      auto_https   off
    '';

    # ACME related settings.
    # email = myvars.useremail;
    # acmeCA = "https://acme-v02.api.letsencrypt.org/directory";

    # Dashboard
    virtualHosts."http://home.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:4401
    '';

    # https://caddyserver.com/docs/caddyfile/directives/file_server
    virtualHosts."http://file.writefor.fun".extraConfig = ''
      root * /var/lib/caddy/fileserver/
      encode zstd gzip
      file_server browse {
        hide .git
        precompressed zstd br gzip
      }
    '';

    # Datastore
    virtualHosts."http://attic.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3300
    '';

    virtualHosts."http://git.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3301
    '';
    virtualHosts."http://sftpgo.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3302
    '';
    virtualHosts."http://webdav.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3303
    '';
    virtualHosts."http://transmission.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:9091
    '';

    # Monitoring
    virtualHosts."http://uptime-kuma.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3350
    '';
    virtualHosts."http://grafana.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3351
    '';
    virtualHosts."http://prometheus.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:9090
    '';
    virtualHosts."http://alertmanager.writefor.fun".extraConfig = ''
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
}
