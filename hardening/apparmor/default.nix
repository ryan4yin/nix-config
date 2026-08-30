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
    # NOTE: these abstractions are FHS-oriented and reference FHS paths. nixpkgs does NOT
    # provide a broad FHS->store alias layer (only /run/current-system, /usr/bin/env and
    # /bin/sh are created), so some referenced paths do not resolve on NixOS and the
    # resulting profiles are incomplete. They are safe only because they run in complain
    # mode (log-only, no blocking); see hardening/README.md.
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

          # NOTE: exec must use the `ix` (inherit) modifier here: abstractions/base
          # pulls in nested rules like `rix` on specific binaries (via xdg-open etc.),
          # and AppArmor 5.0's parser rejects merged rules with conflicting exec
          # modifiers ("profile has merged rule with conflicting x modifiers") when a
          # broad rule uses Ux over those paths.
          profile ${pkgs.sudo}/bin/sudo {
            include <abstractions/base>
            file /** rwlkix,
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
