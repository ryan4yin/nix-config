{
  pkgs,
  lib,
  lanzaboote,
  ...
}:
{
  # Secure Boot here reuses the PKI already enrolled on the Z890 board, carried over with the disk
  # (./README.md step 3). lanzaboote signs with `pkiBundle` below, so a fresh key set must end up in
  # /etc/secureboot — `sbctl create-keys` writes to its own keydir — or the firmware trusts a key the
  # UKI was not signed with. New keys also change PCR7, which invalidates a TPM2 LUKS enrollment made
  # against the old ones (./README.md step 4).
  imports = [
    lanzaboote.nixosModules.lanzaboote
  ];

  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
  ];

  # Lanzaboote replaces the systemd-boot module. The generated
  # hardware-configuration.nix sets this to true, so force it off.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
}
