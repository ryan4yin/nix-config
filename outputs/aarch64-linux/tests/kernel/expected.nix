{
  lib,
  outputs,
}: let
  hostsNames = builtins.attrNames outputs.nixosConfigurations;
  expected = lib.genAttrs hostsNames (_: true);
in
  expected
