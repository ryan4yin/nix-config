{
  pkgs,
  ...
}:
{
  # AppArmor in complain mode: log violations instead of blocking.
  services.dbus.apparmor = "enabled";

  security.apparmor = {
    enable = true;

    # FHS-oriented abstractions, incomplete on NixOS; only safe in complain mode.
    packages = [ pkgs.apparmor-profiles ];

    policies.sudo = {
      state = "complain";
      profile = ''
        abi <abi/4.0>,
        include <tunables/global>

        # Confine sudo (complain). `attach_disconnected` lets Nix 2.35's
        # nixos-rebuild set the profile; `ix` keeps the parser happy.
        #
        # /proc/self/ns/mnt has no connected path, so AppArmor denies the open even in
        # complain mode; Nix 2.35's root nix-env opens it in saveMountNamespace(), and
        # nixos-rebuild aborts only while /nix/store is ro (<= 2.34 left it rw until
        # reboot, 2.35 remounts in a namespace).
        # abstractions/base has nested rix rules, and Ux makes AppArmor 5.0 reject
        # the merged rules.
        profile ${pkgs.sudo}/bin/sudo flags=(attach_disconnected) {
          include <abstractions/base>
          file /** rwlkix,
        }
      '';
    };
  };
}
