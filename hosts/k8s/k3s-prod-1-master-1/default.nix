{
  config,
  pkgs,
  myvars,
  mylib,
  ...
}: let
  hostName = "k3s-prod-1-master-1"; # Define your hostname.

  coreModule = mylib.genKubeVirtCoreModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  k3sModule = mylib.genK3sServerModule {
    inherit pkgs;
    kubeconfigFile = "/home/${myvars.username}/.kube/config";
    tokenFile = config.age.secrets."k3s-prod-1-token".path;
    # the first node in the cluster should be the one to initialize the cluster
    clusterInit = true;
  };
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      coreModule
      k3sModule
    ];
}
