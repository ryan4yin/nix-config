{
  lib,
  outputs,
}:
lib.genAttrs [ "akane" ] (
  name: outputs.nixosConfigurations.${name}.config.system.build.toplevel.drvPath
)
