{ lib, ... }:
{
  # =========================================================================
  #      Base NixOS Configuration
  # =========================================================================

  imports = [
    ../base/core.nix
    ../base/i18n.nix
    ../base/monitoring.nix
    ../base/nix.nix
    ../base/packages.nix
    ../base/ssh.nix
    ../base/user-group.nix

    ../../base
  ];
}
