{
  lib,
  outputs,
}:
lib.genAttrs
(builtins.attrNames outputs.darwinConfigurations)
(
  name: outputs.darwinConfigurations.${name}.config.networking.hostName
)
