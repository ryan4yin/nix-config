{
  pkgs,
  myvars,
  mylib,
  ...
}: let
  hostName = "k3s-prod-1-worker-1"; # define your hostname.
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
    ];
}
