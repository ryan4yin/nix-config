{
  config,
  pkgs,
  mylib,
  myvars,
  disko,
  ...
}:
let
  hostName = "kubevirt-youko"; # Define your hostname.

  coreModule = mylib.genKubeVirtHostModule {
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
    kubeletExtraArgs = [
      "--cpu-manager-policy=static"
      # https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
      # we have to reserve some resources for for system daemons running as pods or system services
      # when cpu-manager's static policy is enabled
      # the memory we reserved here is also for the kernel, since kernel's memory is not accounted in pods
      "--system-reserved=cpu=1,memory=2Gi,ephemeral-storage=2Gi"
    ];
    k3sExtraArgs = [
      # IPv4 Private CIDR(full) - 172.16.0.0/12
      # IPv4 Pod     CIDR(full) - fdfd:cafe:00:0000::/64 ~ fdfd:cafe:00:7fff::/64
      # IPv4 Service CIDR(full) - fdfd:cafe:00:8000::/64 ~ fdfd:cafe:00:ffff::/64
      # "--cluster-cidr=172.16.0.0/16,fdfd:cafe:00:0001::/64"
      # "--service-cidr=172.17.0.0/16,fdfd:cafe:00:8001::/112"
    ];
    nodeLabels = [
      "node-purpose=kubevirt"
    ];
    disableFlannel = false;
  };
in
{
  imports = (mylib.scanPaths ./.) ++ [
    disko.nixosModules.default
    ../disko-config/kubevirt-disko-fs.nix
    ../kubevirt-shoryu/hardware-configuration.nix
    ../kubevirt-shoryu/preservation.nix
    coreModule
    k3sModule
  ];

  boot.kernelParams = [
    # disable transparent hugepage(allocate hugepages dynamically)
    "transparent_hugepage=never"

    # https://kubevirt.io/user-guide/compute/hugepages/
    #
    # pre-allocate hugepages manually(for kubevirt guest vms)
    # NOTE: the hugepages allocated here can not be used for other purposes!
    # so we should left some memory for the host OS and other vms that don't use hugepages
    "hugepagesz=1G"
    "hugepages=15" # use 15/24 of the total memory for hugepages

    # https://kubevirt.io/user-guide/compute/host-devices/
    #
    # PCI passthrough
    # "amd_iommu=on" # enable IOMMU
    # "iommu=pt" # use passthrough mode
    # "pcie_acs_override=downstream" # enable ACS override
  ];
}
