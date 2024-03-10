{
  pkgs,
  mylib,
  myvars,
  disko,
  ...
}: let
  hostName = "kubevirt-youko"; # Define your hostname.
  k8sLib = import ../lib.nix;
  coreModule = k8sLib.gencoreModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      coreModule
      disko.nixosModules.default
      ../disko-config/kubevirt-disko-fs.nix
    ];
}
