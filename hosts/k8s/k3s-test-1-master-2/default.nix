{
  config,
  pkgs,
  lib,
  myvars,
  mylib,
  ...
}:
let
  hostName = "k3s-test-1-master-2"; # Define your hostname.

  coreModule = mylib.genMicrovmGuestModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
    vcpu = 2;
    mem = 4096;
    varSize = 20480;
  };
  k3sModule = mylib.genK3sServerModule {
    inherit pkgs;
    kubeconfigFile = "/home/${myvars.username}/.kube/config";
    tokenFile = config.age.secrets."k3s-test-1-token".path;
    # use my own domain & kube-vip's virtual IP for the API server
    # so that the API server can always be accessed even if some nodes are down
    masterHost = "test-cluster-1.writefor.fun";
    metricsBindAddress = myvars.networking.hostsAddr.${hostName}.ipv4;
    # Workloads run on the worker nodes; they do not use a reserved worker-role label.
    nodeTaints = [ "node-role.kubernetes.io/control-plane:NoSchedule" ];
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
