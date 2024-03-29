{
  config,
  pkgs,
  mylib,
  myvars,
  disko,
  ...
}: let
  hostName = "kubevirt-youko"; # Define your hostname.
  k3sServerName = "kubevirt-shoryu";

  coreModule = mylib.genKubeVirtCoreModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  k3sModule = mylib.genK3sServerModule {
    inherit pkgs;
    kubeconfigFile = "/home/${myvars.username}/.kube/config";
    tokenFile = "/run/media/nixos_k3s/kubevirt-k3s-token";
    # use my own domain & kube-vip's virtual IP for the API server
    # so that the API server can always be accessed even if some nodes are down
    masterHost = "kubevirt-cluster-1.writefor.fun";
  };
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      disko.nixosModules.default
      ../disko-config/kubevirt-disko-fs.nix
      ../kubevirt-shoryu/hardware-configuration.nix
      ../kubevirt-shoryu/impermanence.nix
      coreModule
      k3sModule
    ];
}
