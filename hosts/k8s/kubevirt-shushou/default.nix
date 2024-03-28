{
  config,
  pkgs,
  mylib,
  myvars,
  disko,
  ...
}: let
  hostName = "kubevirt-shushou"; # Define your hostname.
  k3sServerName = "kubevirt-shoryu";

  coreModule = mylib.genKubeVirtCoreModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  k3sModule = mylib.genK3sServerModule {
    inherit pkgs;
    kubeconfigFile = "/home/${myvars.username}/.kube/config";
    tokenFile = "/run/media/nixos_k3s/kubevirt-k3s-token";
    serverIp = myvars.networking.hostsAddr.${k3sServerName}.ipv4;
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
