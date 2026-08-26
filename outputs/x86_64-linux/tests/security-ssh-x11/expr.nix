{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name: outputs.nixosConfigurations.${name}.config.services.openssh.settings.X11Forwarding
)
