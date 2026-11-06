{
  lib,
  outputs,
  ...
}:
let
  cfg = outputs.nixosConfigurations.youko.config;
  nginx = cfg.services.nginx;
  substituters = cfg.nix.settings.substituters;
in
{
  nginxEnabled = nginx.enable;
  caddyVhostExists = cfg.services.caddy.virtualHosts ? "nix-cache.writefor.fun";
  lanCacheFirst = lib.hasPrefix "https://nix-cache.writefor.fun/" (builtins.head substituters);
  ustcProxyConfigured = builtins.elem "https://nix-cache.writefor.fun/mirrors.ustc.edu.cn/nix-channels/store" substituters;
  nixosProxyConfigured = builtins.elem "https://nix-cache.writefor.fun/cache.nixos.org" substituters;
  numtideProxyConfigured = builtins.elem "https://nix-cache.writefor.fun/cache.numtide.com" substituters;
  cachixProxyConfigured = builtins.elem "https://nix-cache.writefor.fun/ryan4yin.cachix.org" substituters;
  directFallbacks =
    builtins.elem "https://mirrors.ustc.edu.cn/nix-channels/store" substituters
    && builtins.elem "https://cache.numtide.com" substituters
    && builtins.elem "https://ryan4yin.cachix.org" substituters;
  cacheLivesOnDataVolume = lib.hasInfix "/data/apps/nix-cache-proxy" nginx.appendHttpConfig;
  nixosUpstream = nginx.virtualHosts."nix-cache-proxy".locations."/cache.nixos.org/".proxyPass;
  numtideUpstream = nginx.virtualHosts."nix-cache-proxy".locations."/cache.numtide.com/".proxyPass;
  cachixUpstream = nginx.virtualHosts."nix-cache-proxy".locations."/ryan4yin.cachix.org/".proxyPass;
  ustcUpstream =
    nginx.virtualHosts."nix-cache-proxy".locations."/mirrors.ustc.edu.cn/nix-channels/store/".proxyPass;
}
