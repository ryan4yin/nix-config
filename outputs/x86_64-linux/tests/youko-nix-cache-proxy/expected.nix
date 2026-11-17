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
  nixosUpstream = "https://cache_nixos_org/";
  numtideUpstream = "https://cache_numtide_com/";
  cachixUpstream = "https://ryan4yin_cachix_org/";
  ustcUpstream = "https://mirrors_ustc_edu_cn/nix-channels/store/";
  upstreamServers = {
    cache_nixos_org = [ "cache.nixos.org:443" ];
    cache_numtide_com = [ "cache.numtide.com:443" ];
    mirrors_ustc_edu_cn = [ "mirrors.ustc.edu.cn:443" ];
    ryan4yin_cachix_org = [ "ryan4yin.cachix.org:443" ];
  };
}
