{lib, ...}: {
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

    ../../base.nix
  ];

  boot.loader.timeout = lib.mkForce 3; # wait for 3 seconds to select the boot entry
}
