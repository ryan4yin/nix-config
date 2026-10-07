{
  microvm,
  myvars,
  mylib,
  agenix,
  mysecrets,
  inputs,
  ...
}:
{
  # Run the k3s-test VMs as MicroVMs instead of KubeVirt domains.
  imports = [ microvm.nixosModules.host ];

  microvm.vms.k3s-test-1-master-2 = {
    autostart = true;
    restartIfChanged = true;
    specialArgs = {
      inherit
        inputs
        myvars
        mylib
        agenix
        mysecrets
        ;
    };
    config.imports = [ ../k8s/k3s-test-1-master-2 ];
  };

  # Moved here from shushou after the SSD swap: the 5625U there is weaker and has
  # only 22 GiB, too little for this 16 GiB worker.
  microvm.vms.k3s-test-1-worker-2 = {
    autostart = true;
    restartIfChanged = true;
    specialArgs = {
      inherit
        inputs
        myvars
        mylib
        agenix
        mysecrets
        ;
    };
    config.imports = [ ../k8s/k3s-test-1-worker-2 ];
  };

  # Attach the guest's tap to the VM bridge, the same way the physical NIC is
  # attached. The name is vm<last IP octet> from lib/genMicrovmGuestModule.nix:
  # 192.168.5.115 -> vm115, 192.168.5.112 -> vm112.
  systemd.network.networks."20-vm115" = {
    matchConfig.Name = [ "vm115" ];
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
}
