{ lib, outputs }:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (_: {
  ipv4Restricted = true;
  ipv6RestrictedBeforeTrust = true;
  generatedRestrictionsBeforeTrust = true;
  lanRetained = true;
  tailnetRetained = true;
})
