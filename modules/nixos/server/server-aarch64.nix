{
  lib,
  pkgs,
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
  ];

  # Fix: jasper is marked as broken, refusing to evaluate.
  environment.enableAllTerminfo = lib.mkForce false;
}
