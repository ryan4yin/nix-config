{
  config,
  pkgs,
  mylib,
  myvars,
  disko,
  ...
}:
let
  hostName = "shushou"; # Define your hostname.

  coreModule = mylib.genVmHostModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  resticModule = mylib.genResticBackup {
    inherit pkgs hostName;
  };
in
{
  imports = (mylib.scanPaths ./.) ++ [
    disko.nixosModules.default
    ../k8s/disko-config/host-disko-fs.nix
    ../12kingdoms-shoryu/hardware-configuration.nix
    ../12kingdoms-shoryu/preservation.nix
    coreModule
  ];

  modules.btrbk.enable = true;

  boot.kernelParams = [
    # Use transparent huge pages on demand (madvise) instead of a fixed 1G hugetlb
    # pool. The static pool cannot be overcommitted or shared with the host /
    # other VMs, which stranded memory and blocked scheduling; the VMs now use
    # ordinary memory (see the instancetypes in k8s-gitops).
    "transparent_hugepage=madvise"
  ];
}
