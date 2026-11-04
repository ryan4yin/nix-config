{
  inputs,
  mylib,
  outputs,
  ...
}:
let
  pkgs = outputs.nixosConfigurations.ai-niri.pkgs;
  hostConfig = outputs.nixosConfigurations.ai-niri.config;
in
# The sandboxes pass TZ through from the session environment.
assert hostConfig.environment.sessionVariables.TZ == hostConfig.time.timeZone;
import ../../../../hardening/tests/policy.nix {
  inherit pkgs mylib;
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit pkgs;
    inherit (pkgs) lib;
  };
}
