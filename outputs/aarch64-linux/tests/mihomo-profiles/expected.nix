{ lib, outputs, ... }:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (_: {
  profilesGroupDeclared = true;
  profilesSafePath = true;
  profilesSupplementaryGroup = true;
})
