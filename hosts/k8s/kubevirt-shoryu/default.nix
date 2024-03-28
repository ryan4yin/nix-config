{
  config,
  pkgs,
  mylib,
  myvars,
  disko,
  ...
}: let
  # MoreFine - S500Plus
  hostName = "kubevirt-shoryu"; # Define your hostname.

  coreModule = mylib.genKubeVirtCoreModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  k3sModule = mylib.genK3sServerModule {
    inherit pkgs;
    kubeconfigFile = "/home/${myvars.username}/.kube/config";
    tokenFile = "/run/media/nixos_k3s/kubevirt-k3s-token";
    # the first node in the cluster should be the one to initialize the cluster
    clusterInit = true;
  };
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      disko.nixosModules.default
      ../disko-config/kubevirt-disko-fs.nix
      ./hardware-configuration.nix
      ./impermanence.nix
      coreModule
      k3sModule
    ];
}
