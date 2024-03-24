{
  lib,
  outputs,
}: let
  hostsNames = builtins.attrNames outputs.nixosConfigurations;
  expected = lib.genAttrs hostsNames (_: "x86_64-linux");
in
  expected
