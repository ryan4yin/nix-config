{
  pkgs,
  mylib,
  vars_networking,
  disko,
  ...
}: let
  hostName = "kubevirt-youko"; # Define your hostname.
  k8sLib = import ../lib.nix;
  coreModule = k8sLib.gencoreModule {
    inherit pkgs hostName vars_networking;
  };
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      coreModule
      disko.nixosModules.default
      ../kubevirt-disko-fs.nix
    ];
}
