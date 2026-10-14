{ outputs, ... }:
let
  system = outputs.nixosConfigurations.shoukei-niri.config;
  nm = system.networking.networkmanager;
in
{
  resolved = system.services.resolved.enable;
  resolvconf = system.networking.resolvconf.enable;
  dnsBackend = nm.dns;
  tunUnmanaged = builtins.elem "interface-name:Meta" nm.unmanaged;
  dispatcherCount = builtins.length nm.dispatcherScripts;
  resolverOrdered = builtins.elem "systemd-resolved.service" system.systemd.services.mihomo.after;
  resolverRequired = builtins.elem "systemd-resolved.service" system.systemd.services.mihomo.requires;
}
