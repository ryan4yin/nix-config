{ myvars, ... }:
let
  cacheDir = "/data/apps/nix-cache-proxy";
  inherit (myvars.ports) youkoNixCacheProxy;

  # Nix clients verify narinfo signatures and NAR hashes, so this only needs to
  # be a transparent HTTP cache, not a Nix-aware store. Keep it on the btrfs
  # data volume, never on the /data tmpfs.
  cacheConfig = ''
    proxy_ssl_server_name on;
    proxy_ssl_verify on;
    proxy_ssl_verify_depth 3;
    proxy_ssl_trusted_certificate /etc/ssl/certs/ca-bundle.crt;

    proxy_cache nix_cache;
    proxy_cache_key "$scheme$request_method$host$request_uri";
    proxy_cache_valid 200 206 30d;
    proxy_cache_valid 404 1m;
    proxy_cache_lock on;
    proxy_cache_lock_timeout 60s;
    proxy_cache_use_stale
      error timeout updating
      http_500 http_502 http_503 http_504;

    add_header X-Cache-Status $upstream_cache_status always;
  '';

  cacheLocation = upstream: subPath: {
    proxyPass = "https://${upstream}${subPath}/";
    extraConfig = ''
      proxy_set_header Host ${upstream};
      ${cacheConfig}
    '';
  };
in
{
  services.nginx = {
    enable = true;

    appendHttpConfig = ''
      proxy_cache_path ${cacheDir}
        levels=1:2
        keys_zone=nix_cache:256m
        max_size=300g
        inactive=30d
        use_temp_path=off;
    '';

    virtualHosts."nix-cache-proxy" = {
      # Caddy owns the public listener and terminates HTTPS; nginx is internal.
      listen = [
        {
          addr = "127.0.0.1";
          port = youkoNixCacheProxy;
        }
      ];

      locations = {
        "/cache.nixos.org/" = cacheLocation "cache.nixos.org" "";
        "/cache.numtide.com/" = cacheLocation "cache.numtide.com" "";
        "/ryan4yin.cachix.org/" = cacheLocation "ryan4yin.cachix.org" "";
        # The mirror keeps the upstream path under /nix-channels/store.
        "/mirrors.ustc.edu.cn/nix-channels/store/" =
          cacheLocation "mirrors.ustc.edu.cn" "/nix-channels/store";
      };
    };
  };

  # `proxy_cache_path` is created at runtime; nginx owns it.
  systemd.tmpfiles.rules = [
    "d ${cacheDir} 0755 nginx nginx - -"
  ];
  systemd.services.nginx = {
    unitConfig.RequiresMountsFor = [ "/data/apps" ];
    # The NixOS nginx unit runs with ProtectSystem=strict; the custom cache
    # path must be explicitly writable.
    serviceConfig.ReadWritePaths = [ cacheDir ];
  };

  # Public Let's Encrypt wildcard, already managed by the Caddy module. This
  # avoids distributing the private homelab CA to clients that only consume the
  # cache (including macOS).
  services.caddy.virtualHosts."nix-cache.writefor.fun".extraConfig = ''
    tls /var/lib/acme/writefor.fun/fullchain.pem /var/lib/acme/writefor.fun/key.pem {
      protocols tls1.3 tls1.3
      curves x25519 secp384r1 secp521r1
    }
    reverse_proxy http://127.0.0.1:${toString youkoNixCacheProxy}
  '';
}
