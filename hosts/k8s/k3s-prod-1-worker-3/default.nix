{
  config,
  pkgs,
  myvars,
  mylib,
  ...
}: let
  hostName = "k3s-prod-1-worker-3"; # define your hostname.

  coreModule = mylib.genKubeVirtGuestModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  k3sModule = mylib.genK3sAgentModule {
    inherit pkgs;
    tokenFile = config.age.secrets."k3s-prod-1-token".path;
    # use my own domain & kube-vip's virtual IP for the API server
    # so that the API server can always be accessed even if some nodes are down
    masterHost = "prod-cluster-1.writefor.fun";
  };
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      coreModule
      k3sModule
    ];
}
