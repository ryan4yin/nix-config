{
  lib,
  pkgs,
  mylib,
  ...
}:
{
  imports = [
    ../base/btrbk.nix
    ../base/core.nix
    ../base/i18n.nix
    ../base/monitoring.nix
    ../base/nix.nix
    ../base/packages.nix
    ../base/ssh.nix
    ../base/user-group.nix

    ../../base
    # AppArmor is wired via modules/nixos/base/default.nix for other hosts; this
    # aarch64 server imports base files individually, so add it explicitly.
    (mylib.relativeToRoot "hardening/apparmor")
  ];

  # Servers run on the trusted internal LAN (NAT'd; WAN protected at the router).
  # Keep the firewall off here; the secure default is ON (see modules/nixos/base/ssh.nix).
  networking.firewall.enable = false;

  # Fix: jasper is marked as broken, refusing to evaluate.
  environment.enableAllTerminfo = lib.mkForce false;
}
