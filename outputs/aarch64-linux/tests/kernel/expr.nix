{
  lib,
  outputs,
}:
lib.genAttrs
(builtins.attrNames outputs.nixosConfigurations)
(
  name: outputs.nixosConfigurations.${name}.config.boot.kernelPackages.kernel.system
)
