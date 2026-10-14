{
  lib,
  myvars,
  outputs,
  ...
}:
let
  cfg = outputs.nixosConfigurations.ai-niri.config;
  hm = cfg.home-manager.users.${myvars.username};
  inherit (myvars.networking.hostsAddr.ai) iface ipv4;
  # Read the file that actually gets installed, not the path in the repository.
  noctalia = builtins.readFile hm.xdg.configFile."noctalia/host-ai.toml".source;
in
{
  # A board or PCIe change renames the wired NIC with the PCIe topology, so networkd
  # matches the `en*` prefix; a name-based match left the host off the LAN.
  staticAddressMatchesWiredInterface =
    builtins.elem "${ipv4}/24" cfg.systemd.network.networks."10-lan".networkConfig.Address
    && cfg.systemd.network.networks."10-lan".matchConfig.Name == [ "en*" ];

  # The two consumers that need one exact name — mihomo's DNS hook and Noctalia's
  # net-speed widgets — take it from `hostsAddr.ai.iface`; each widget is asserted
  # on its own, so a drift in either one fails.
  noctaliaReadsHostIface =
    lib.hasInfix "[widget.net_rx]\ninterface = \"${iface}\"" noctalia
    && lib.hasInfix "[widget.net_tx]\ninterface = \"${iface}\"" noctalia;
}
