{
  microvm,
  inputs,
  ...
}:
{
  # Run the k3s-test VMs as MicroVMs instead of KubeVirt domains.
  imports = [ microvm.nixosModules.host ];

  # Each guest runs its `nixosConfigurations` entry, the system that `just test`
  # and `just microvm-deploy` see, instead of a second evaluation on the host.
  microvm.vms.k3s-test-1-master-1 = {
    autostart = true;
    restartIfChanged = true;
    evaluatedConfig = inputs.self.nixosConfigurations.k3s-test-1-master-1;
  };

  microvm.vms.k3s-test-1-worker-1 = {
    autostart = true;
    restartIfChanged = true;
    evaluatedConfig = inputs.self.nixosConfigurations.k3s-test-1-worker-1;
  };

  # Attach the guest's tap to the VM bridge, the same way the physical NIC is
  # attached. The tap name is derived from the guest IP (192.168.5.114 -> vm114,
  # 192.168.5.111 -> vm111), as IFNAMSIZ caps interface names at 15 characters.
  systemd.network.networks."20-vm114" = {
    matchConfig.Name = [ "vm114" ];
    networkConfig = {
      LinkLocalAddressing = "no";
      Bridge = "br0";
    };
    linkConfig.RequiredForOnline = "no";
  };
  systemd.network.networks."20-vm111" = {
    matchConfig.Name = [ "vm111" ];
    networkConfig = {
      LinkLocalAddressing = "no";
      Bridge = "br0";
    };
    linkConfig.RequiredForOnline = "no";
  };
}
