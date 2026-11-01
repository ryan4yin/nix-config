{
  inputs,
  mylib,
  outputs,
  ...
}:
let
  pkgs = outputs.nixosConfigurations.ai-niri.pkgs;
in
import ../../../../hardening/tests/policy.nix {
  inherit pkgs mylib;
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit pkgs;
    inherit (pkgs) lib;
  };
}
