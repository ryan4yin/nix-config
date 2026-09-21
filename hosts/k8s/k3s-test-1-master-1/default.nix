{
  config,
  pkgs,
  lib,
  myvars,
  mylib,
  ...
}:
let
  hostName = "k3s-test-1-master-1"; # Define your hostname.

  coreModule = mylib.genMicrovmGuestModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
    vcpu = 2;
    mem = 8192;
    varSize = 20480;
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
    # the control plane only runs the control plane; workloads run on the
    # k3s-test-1-worker-* nodes (labelled node-role.kubernetes.io/worker=true)
    nodeTaints = [ "node-role.kubernetes.io/control-plane:NoSchedule" ];

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
  imports =
    (mylib.scanPaths ./.)
    ++ (map mylib.relativeToRoot [
      "secrets/nixos.nix"
      "modules/nixos/server/server.nix"
    ])
    ++ [
      coreModule
      k3sModule
    ];

  # k3s-test-1-token lives in this secret group
  modules.secrets.server.kubernetes.enable = true;

  # The guest reuses the host's already-instantiated nixpkgs (shared store),
  # so nixpkgs.config may not be set. The shared base modules set
  # nixpkgs.config.allowUnfree, so force it empty here.
  nixpkgs.config = lib.mkForce { };
}
