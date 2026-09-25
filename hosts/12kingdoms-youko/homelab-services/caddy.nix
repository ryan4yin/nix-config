{
  mylib,
  pkgs,
  config,
  wallpapers,
  ...
}:
let
  hostCommonConfig = ''
    encode zstd gzip
    tls ${mylib.relativeToRoot "certs/ecc-server.crt"} ${
      config.age.secrets."caddy-ecc-server.key".path
    } {
      protocols tls1.3 tls1.3
      curves x25519 secp384r1 secp521r1
    }
  '';
in
{
  services.caddy = {
    enable = true;
    # Reload Caddy instead of restarting it when configuration file changes.
    enableReload = true;
    user = "caddy"; # User account under which caddy runs.
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
      reverse_proxy http://localhost:54401
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
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3301
    '';
    virtualHosts."sftpgo.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3302
    '';
    virtualHosts."webdav.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3303
    '';
    # the restic REST server the backup clients push to
    virtualHosts."restic.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      # metrics are scraped over loopback only, never through this vhost
      @metrics path /metrics
      respond @metrics 403
      reverse_proxy http://localhost:8000
    '';
    # RustFS replaced MinIO. SigV4 signs the Host header, so preserve it. No
    # `encode` here: compression would corrupt range/streaming responses.
    virtualHosts."s3.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      reverse_proxy http://localhost:9000 {
        header_up Host {http.request.host}
        transport http {
          dial_timeout 300s
          read_timeout 300s
          write_timeout 300s
        }
      }
    '';
    # RustFS management console (websockets). The UI is served under
    # /rustfs/console/. The console frontend signs its own S3/STS calls to `/`
    # (POST / for STS, GET /?x-id=ListBuckets), so only redirect a plain browser
    # visit (unsigned GET /) to the UI; signed requests must reach RustFS as-is.
    virtualHosts."s3-console.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      @console_root {
        method GET
        path /
        not header Authorization *
      }
      redir @console_root /rustfs/console/ 302
      reverse_proxy http://localhost:9001 {
        header_up Host {http.request.host}
        header_up Upgrade {http.request.header.Upgrade}
        header_up Connection {http.request.header.Connection}
        transport http {
          dial_timeout 300s
          read_timeout 300s
          write_timeout 300s
        }
      }
    '';
    # Every other name is not a service on this host: answer 404 instead of
    # caddy's empty 200 fallback, which hides typos.
    virtualHosts."*.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      respond 404
    '';
    virtualHosts."transmission.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9091
    '';

    # Monitoring
    virtualHosts."uptime-kuma.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:53350
    '';
    virtualHosts."grafana.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3351
    '';
    virtualHosts."prometheus.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9090
    '';
    virtualHosts."alertmanager.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9093
    '';
    virtualHosts."vmalert.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:8880
    '';
    # Allow http access for specific api (do not redirect to https)
    # virtualHosts."http://xxx.writefor.fun/a/b/c".extraConfig = ''
    #   encode zstd gzip
    #   reverse_proxy http://localhost:9090
    # '';
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  # Serve the wallpapers from the file server. `mkdir -p` here covers the
  # whole fileserver tree; caddy's dataDir itself is created by the module.
  system.activationScripts.installCaddyWallpapers = ''
    mkdir -p /var/lib/caddy/fileserver/wallpapers
    ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F644 ${wallpapers}/ /var/lib/caddy/fileserver/wallpapers/
  '';
}
