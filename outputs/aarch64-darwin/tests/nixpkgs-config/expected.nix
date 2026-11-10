{
  lib,
  outputs,
}:
let
  hostsNames = builtins.attrNames outputs.darwinConfigurations;
  # nix-darwin passes an external instance through `nixpkgs.pkgs`, and nixpkgs
  # asserts that `nixpkgs.config` stays empty in that case.
  expected = lib.genAttrs hostsNames (_: true);
in
expected
