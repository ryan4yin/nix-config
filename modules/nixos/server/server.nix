{ ... }:
{
  imports = [
    ../base
    ../../base
  ];

  # Servers used to keep the firewall off, trusting the router alone. They now
  # run the shared base firewall (modules/nixos/base/networking/firewall.nix)
  # like every other host, as defence in depth behind the router.
}
