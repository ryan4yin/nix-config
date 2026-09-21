{
  microvm,
  myvars,
  mylib,
  agenix,
  mysecrets,
  ...
}:
{
  # Run the k3s-test VMs as MicroVMs instead of KubeVirt domains.
  imports = [ microvm.nixosModules.host ];

  microvm.vms.k3s-test-1-master-1 = {
    autostart = true;
    restartIfChanged = true;
    specialArgs = {
      inherit
        myvars
        mylib
        agenix
        mysecrets
        ;
    };
    config.imports = [ ../k3s-test-1-master-1 ];
  };

  # Attach the guest's tap to the VM bridge, the same way the physical NIC is
  # attached. The tap name is derived from the guest IP (192.168.5.114 -> vm114).
  systemd.network.networks."20-vm114" = {
    matchConfig.Name = [ "vm114" ];
    networkConfig = {
      LinkLocalAddressing = "no";
      Bridge = "br0";
    };
    linkConfig.RequiredForOnline = "no";
  };
}
