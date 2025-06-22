{
  lib,
  outputs,
}:
lib.genAttrs
(builtins.attrNames outputs.nixosConfigurations)
(
  name: outputs.nixosConfigurations.${name}.config.networking.hostName
)
