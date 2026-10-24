{ lib, outputs }:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (_: {
  ipv4Restricted = true;
  exportersBoundToLan = true;
  ipv6RestrictedBeforeTrust = true;
  generatedRestrictionsBeforeTrust = true;
  lanRetained = true;
  tailnetRetained = true;
})
