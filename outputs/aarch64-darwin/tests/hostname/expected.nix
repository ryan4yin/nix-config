{
  lib,
  outputs,
}: let
  hostsNames = builtins.attrNames outputs.darwinConfigurations;
  expected = lib.genAttrs hostsNames (name: name);
in
  expected
