{useremail, ...}: {
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
    # email = useremail;
    # acmeCA = "https://acme-v02.api.letsencrypt.org/directory";

    virtualHosts."http://grafana.writefor.fun".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://localhost:3000
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
}
