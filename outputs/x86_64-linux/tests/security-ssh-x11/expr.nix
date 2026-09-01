{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    settings = outputs.nixosConfigurations.${name}.config.services.openssh.settings;
  in
  {
    inherit (settings) PermitRootLogin X11Forwarding;
  }
)
