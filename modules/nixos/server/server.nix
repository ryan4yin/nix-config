{ ... }:
{
  imports = [
    ../base
    ../nushell-login.nix
    ../../base
  ];

  # RAPL is a local side channel, so exposure is opt-in and scoped to the
  # server role. Desktops keep the kernel-default root-only energy_uj.
  modules.powerMonitoring.enable = true;

  # Servers used to keep the firewall off, trusting the router alone. They now
  # run the shared base firewall (modules/nixos/base/networking/firewall.nix)
  # like every other host, as defence in depth behind the router.
}
