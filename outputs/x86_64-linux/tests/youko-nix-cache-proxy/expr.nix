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
  ustcRemainsFirst = builtins.head substituters == "https://mirrors.ustc.edu.cn/nix-channels/store";
  nixosProxyConfigured = builtins.elem "https://nix-cache.writefor.fun/cache.nixos.org" substituters;
  numtideProxyConfigured = builtins.elem "https://nix-cache.writefor.fun/cache.numtide.com" substituters;
  numtideDirectFallback = builtins.elem "https://cache.numtide.com" substituters;
  cacheLivesOnDataVolume = lib.hasInfix "/data/apps/nix-cache-proxy" nginx.appendHttpConfig;
  nixosUpstream = nginx.virtualHosts."nix-cache-proxy".locations."/cache.nixos.org/".proxyPass;
  numtideUpstream = nginx.virtualHosts."nix-cache-proxy".locations."/cache.numtide.com/".proxyPass;
}
