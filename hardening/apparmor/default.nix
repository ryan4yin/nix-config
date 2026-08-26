{
  config,
  pkgs,
  ...
}:
{
  # AppArmor: activate the LSM + load policies. Roll out in complain mode first
  # (log violations, never block) so nothing can break; promote profiles to
  # "enforce" individually once stable.
  services.dbus.apparmor = "enabled";

  security.apparmor = {
    enable = true;

    # Do not SIGTERM running unconfined-but-confinable processes yet.
    # Safe to flip to true later now that no global default-deny profile is active.
    killUnconfinedConfinables = false;

    # Packages contributing to AppArmor's include path (abstractions).
    # NOTE: these are FHS-oriented; nixpkgs adds FHS->NixOS aliases so they mostly work,
    # but treat resulting profiles as complain-only until verified.
    packages = [ pkgs.apparmor-profiles ];

    policies = {
      # Global default-deny scaffold. DANGEROUS to enable: `/**` matches every binary and
      # the empty block allows nothing. Keep disabled until per-app profiles exist.
      "default_deny" = {
        state = "disable";
        profile = "profile default_deny /** { }";
      };

      # Confine sudo; complain mode so a missing rule logs instead of blocking.
      "sudo" = {
        state = "complain";
        profile = ''
          abi <abi/4.0>,
          include <tunables/global>

          profile ${pkgs.sudo}/bin/sudo {
            include <abstractions/base>
            file /** rwlkUx,
          }
        '';
      };

      # nix runs unconfined (no restriction); inert, kept disabled.
      "nix" = {
        state = "disable";
        profile = "profile ${config.nix.package}/bin/nix { unconfined, }";
      };
    };
  };
}
