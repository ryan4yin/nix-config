{ lib, ... }:
{
  imports = [
    ../base
    ../../base
  ];

  # Servers run on the trusted internal LAN (NAT'd; WAN protected at the router).
  # Keep the firewall off here; the secure default is ON (see modules/nixos/base/ssh.nix).
  networking.firewall.enable = false;
}
