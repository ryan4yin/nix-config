{
  vars_networking,
  mylib,
  ...
}: let
  hostName = "k3s-prod-1-master-2"; # Define your hostname.
  k8sLib = import ../lib.nix;
  coreModule = k8sLib.genCoreModule {
    inherit hostName vars_networking;
  };
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      coreModule
    ];
}
