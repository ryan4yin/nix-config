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

  microvm.vms.k3s-test-1-master-3 = {
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
    config.imports = [ ../k8s/k3s-test-1-master-3 ];
  };

  microvm.vms.k3s-test-1-worker-2 = {
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
    config.imports = [ ../k8s/k3s-test-1-worker-2 ];
  };

  microvm.vms.k3s-test-1-worker-3 = {
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
    config.imports = [ ../k8s/k3s-test-1-worker-3 ];
  };

  # Attach the guest's tap to the VM bridge, the same way the physical NIC is
  # attached. The tap name is derived from the guest IP (192.168.5.116 -> vm116,
  # 192.168.5.112 -> vm112, 192.168.5.113 -> vm113), as IFNAMSIZ caps interface
  # names at 15 characters.
  systemd.network.networks."20-vm116" = {
    matchConfig.Name = [ "vm116" ];
    networkConfig = {
      LinkLocalAddressing = "no";
      Bridge = "br0";
    };
    linkConfig.RequiredForOnline = "no";
  };
  systemd.network.networks."20-vm112" = {
    matchConfig.Name = [ "vm112" ];
    networkConfig = {
      LinkLocalAddressing = "no";
      Bridge = "br0";
    };
    linkConfig.RequiredForOnline = "no";
  };
  systemd.network.networks."20-vm113" = {
    matchConfig.Name = [ "vm113" ];
    networkConfig = {
      LinkLocalAddressing = "no";
      Bridge = "br0";
    };
    linkConfig.RequiredForOnline = "no";
  };
}
