{
  config,
  pkgs,
  myvars,
  mylib,
  ...
}:
let
  hostName = "k3s-test-1-master-1"; # Define your hostname.

  coreModule = mylib.genKubeVirtGuestModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  k3sModule = mylib.genK3sServerModule {
    inherit pkgs;
    kubeconfigFile = "/home/${myvars.username}/.kube/config";
    tokenFile = config.age.secrets."k3s-test-1-token".path;
    # the first node in the cluster should be the one to initialize the cluster
    clusterInit = true;
    # use my own domain & kube-vip's virtual IP for the API server
    # so that the API server can always be accessed even if some nodes are down
    masterHost = "test-cluster-1.writefor.fun";

    # k3sExtraArgs = [
    #   # IPv4 Private CIDR(full) - 172.16.0.0/12
    #   # IPv4 Pod     CIDR(full) - fdfd:cafe:00:0000::/64 ~ fdfd:cafe:00:7fff::/64
    #   # IPv4 Service CIDR(full) - fdfd:cafe:00:8000::/64 ~ fdfd:cafe:00:ffff::/64
    #   "--cluster-cidr=172.18.0.0/16,fdfd:cafe:00:0002::/64"
    #   "--service-cidr=172.19.0.0/16,fdfd:cafe:00:8002::/112"
    # ];
  };
in
{
  imports = (mylib.scanPaths ./.) ++ [
    coreModule
    k3sModule
  ];
}
