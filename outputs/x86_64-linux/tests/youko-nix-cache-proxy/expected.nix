{
  nginxEnabled = true;
  caddyVhostExists = true;
  lanCacheFirst = true;
  ustcProxyConfigured = true;
  nixosProxyConfigured = true;
  numtideProxyConfigured = true;
  cachixProxyConfigured = true;
  directFallbacks = true;
  cacheLivesOnDataVolume = true;
  nixosUpstream = "https://cache.nixos.org/";
  numtideUpstream = "https://cache.numtide.com/";
  cachixUpstream = "https://ryan4yin.cachix.org/";
  ustcUpstream = "https://mirrors.ustc.edu.cn/nix-channels/store/";
}
