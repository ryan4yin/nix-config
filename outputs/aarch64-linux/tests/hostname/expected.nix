{
  lib,
  outputs,
}: let
  hostsNames = builtins.attrNames outputs.nixosConfigurations;
  expected = lib.genAttrs hostsNames (name: name);
in
  expected
