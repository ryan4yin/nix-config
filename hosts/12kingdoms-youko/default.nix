{
  config,
  pkgs,
  mylib,
  myvars,
  disko,
  ...
}:
let
  hostName = "youko"; # Define your hostname.

  coreModule = mylib.genVmHostModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
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
    # pool (cannot be overcommitted/shared; it stranded memory and blocked
    # scheduling). The VMs now use ordinary memory.
    "transparent_hugepage=madvise"

    # https://kubevirt.io/user-guide/compute/host-devices/
    #
    # PCI passthrough
    # "amd_iommu=on" # enable IOMMU
    # "iommu=pt" # use passthrough mode
    # "pcie_acs_override=downstream" # enable ACS override
  ];
}
