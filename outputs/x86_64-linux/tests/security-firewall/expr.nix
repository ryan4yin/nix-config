{
  myvars,
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    firewall = outputs.nixosConfigurations.${name}.config.networking.firewall;
  in
  # Every host must run the shared firewall (modules/nixos/base/networking/
  # firewall.nix): enabled, trusting the LAN by source, and opening nothing to
  # the Internet through the global port lists.
  firewall.enable
  && lib.hasInfix myvars.networking.lanCidr firewall.extraInputRules
  && firewall.allowedTCPPorts == [ ]
  && firewall.allowedUDPPorts == [ ]
)
