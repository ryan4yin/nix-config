{ lib, ... }:
{
  # =========================================================================
  #      Base NixOS Configuration
  # =========================================================================

  imports = [
    ../base/btop.nix
    ../base/core.nix
    ../base/i18n.nix
    ../../../hardening/kernel-hardening.nix
    ../base/monitoring.nix
    ../base/nix.nix
    ../base/packages.nix
    ../base/ssh.nix
    ../base/user-group.nix

    # This server imports base files individually instead of the whole
    # modules/nixos/base group, so pull the shared firewall in explicitly.
    ../base/networking/firewall.nix

    ../../base
  ];
}
