{
  lib,
  outputs,
}:
lib.genAttrs [ "kana" ] (
  name: outputs.nixosConfigurations.${name}.config.system.build.toplevel.drvPath
)
