{
  mylib,
  pkgs,
  config,
  myvars,
  wallpapers,
  ...
}:
let
  # TLS for LAN-only services, served with the homelab's self-signed `ecc-ca`
  # certificate. Only clients that already installed the private CA (this
  # repo's desktops/servers, via `modules/base/security.nix`) trust it.
  # Mobile apps do NOT trust a private CA, so any site a phone must reach uses
  # `publicClientTlsConfig` instead of this one.
  privateTlsConfig = ''
    encode zstd gzip
    tls ${mylib.relativeToRoot "certs/ecc-server.crt"} ${
      config.age.secrets."caddy-ecc-server.key".path
    } {
      protocols tls1.3 tls1.3
      curves x25519 secp384r1 secp521r1
    }
  '';

  # TLS for sites that must be reachable from unmodified mobile apps. The cert
  # is issued by a public CA (Let's Encrypt) so the phone app trusts it without
  # installing `ecc-ca`. Caddy does NOT issue it: auto-HTTPS is off
  # (`auto_https disable_certs`) and the private wildcard cert already covers
  # every `*.writefor.fun` name, so caddy would refuse to manage this one.
  # Instead NixOS `security.acme` (lego) runs the ACME DNS-01 challenge against
  # the Cloudflare zone (see the `security.acme` block below) and caddy only
  # loads the resulting files. DNS-01 needs no inbound ports or public IP, so
  # the service stays on the LAN; the hostname does appear in public CT logs.
  publicClientTlsConfig = domain: ''
    encode zstd gzip
    tls /var/lib/acme/${domain}/fullchain.pem /var/lib/acme/${domain}/key.pem {
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
      ${privateTlsConfig}
      reverse_proxy http://localhost:54401
    '';

    # https://caddyserver.com/docs/caddyfile/directives/file_server
    virtualHosts."file.writefor.fun".extraConfig = ''
      root * /var/lib/caddy/fileserver/
      ${privateTlsConfig}
      file_server browse {
        hide .git
        precompressed zstd br gzip
      }
    '';

    virtualHosts."git.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3301
    '';
    virtualHosts."sftpgo.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3302
    '';
    virtualHosts."webdav.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3303
    '';
    # the restic REST server the backup clients push to
    virtualHosts."restic.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      # metrics are scraped over loopback only, never through this vhost
      @metrics path /metrics
      respond @metrics 403
      reverse_proxy http://localhost:8000
    '';
    # RustFS replaced MinIO. SigV4 signs the Host header, so preserve it. No
    # `encode` here: compression would corrupt range/streaming responses.
    virtualHosts."s3.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
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
      ${privateTlsConfig}
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
    # Immich photo library (websockets for live updates). Uploads stream through
    # Caddy, which has no request-body limit by default.
    # Unlike the LAN-only services above, this one is opened from the Immich
    # mobile app, which refuses the private `ecc-ca` certificate -- so it gets a
    # publicly-trusted Let's Encrypt cert instead (see `publicClientTlsConfig`).
    virtualHosts."immich.writefor.fun".extraConfig = ''
      ${publicClientTlsConfig "immich.writefor.fun"}
      reverse_proxy http://localhost:2283 {
        header_up Host {http.request.host}
      }
    '';
    # Every other name is not a service on this host: answer 404 instead of
    # caddy's empty 200 fallback, which hides typos.
    virtualHosts."*.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      respond 404
    '';
    virtualHosts."transmission.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9091
    '';

    # Monitoring
    virtualHosts."uptime-kuma.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      encode zstd gzip
      reverse_proxy http://localhost:53350
    '';
    virtualHosts."grafana.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3351
    '';
    virtualHosts."prometheus.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9090
    '';
    virtualHosts."alertmanager.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9093
    '';
    virtualHosts."vmalert.writefor.fun".extraConfig = ''
      ${privateTlsConfig}
      encode zstd gzip
      reverse_proxy http://localhost:8880
    '';
    # Allow http access for specific api (do not redirect to https)
    # virtualHosts."http://xxx.writefor.fun/a/b/c".extraConfig = ''
    #   encode zstd gzip
    #   reverse_proxy http://localhost:9090
    # '';
  };

  # Issue the certs for `publicClientTlsConfig` sites with lego (packaged in
  # nixpkgs, so no custom caddy build is needed) via the ACME DNS-01 challenge
  # against the Cloudflare-managed `writefor.fun` zone. The token is an agenix
  # environment file holding `CLOUDFLARE_DNS_API_TOKEN=...`.
  security.acme = {
    acceptTerms = true;
    # lego runs as the unprivileged `acme` user by default, which cannot read
    # the root-owned agenix file; run it as root so it can.
    useRoot = true;
    defaults.email = myvars.useremail;
    certs."immich.writefor.fun" = {
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets."cloudflare-dns-api-token".path;
      # lego's own propagation checks are unreliable from youko (its resolver
      # never sees the fresh challenge TXT in time), so replace them with a
      # fixed wait; the CA still verifies the record from the public internet.
      extraLegoRunFlags = [
        "--dns.propagation.wait"
        "60s"
      ];
      extraLegoRenewFlags = [
        "--dns.propagation.wait"
        "60s"
      ];
      # let the caddy user read the issued cert/key
      group = "caddy";
      # caddy keeps running and loads the new cert on renewal
      reloadServices = [ "caddy.service" ];
    };
  };

  # caddy loads the lego-issued files at startup, so wait for the acme service;
  # otherwise its config fails to load before the cert exists.
  systemd.services.caddy = {
    wants = [ "acme-immich.writefor.fun.service" ];
    after = [ "acme-immich.writefor.fun.service" ];
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
