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
    tokenFile = config.age.secrets."k3s-prod-1-token".path;
    serverIp = myvars.networking.hostsAddr.${k3sServerName}.ipv4;
  };
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      disko.nixosModules.default
      ../disko-config/kubevirt-disko-fs.nix
      coreModule
      k3sModule
    ];
}
