{
  config,
  pkgs,
  myvars,
  mylib,
  ...
}: let
  hostName = "k3s-prod-1-master-3"; # define your hostname.
  k3sServerName = "k3s-prod-1-master-1";

  coreModule = mylib.genKubeVirtCoreModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  k3sModule = mylib.genK3sServerModule {
    inherit pkgs;
    kubeconfigFile = "/home/${myvars.username}/.kube/config";
    tokenFile = config.age.secrets."k3s-prod-1-token".path;
    serverIp = myvars.networking.hostsAddr.${k3sServerName}.ipv4;
  };
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      coreModule
      k3sModule
    ];
}
