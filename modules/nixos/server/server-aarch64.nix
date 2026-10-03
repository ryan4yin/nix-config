{
  mylib,
  ...
}:
{
  imports = [
    ../base/btrbk.nix
    ../base/btop.nix
    ../base/core.nix
    ../base/i18n.nix
    ../base/kernel-hardening.nix
    ../base/kernel-status.nix
    ../base/monitoring.nix
    ../base/nix.nix
    ../base/packages.nix
    ../base/ssh.nix
    ../base/user-group.nix

    # This server imports base files individually instead of the whole
    # modules/nixos/base group, so pull the shared firewall in explicitly.
    ../base/networking/firewall.nix

    ../../base
    # AppArmor is wired via modules/nixos/base/default.nix for other hosts; this
    # aarch64 server imports base files individually, so add it explicitly.
    (mylib.relativeToRoot "hardening/apparmor")
  ];

}
