{
  lib,
  outputs,
}:
lib.genAttrs
(builtins.attrNames outputs.nixosConfigurations)
(
  # test only if kernelPackages is set, to avoid build the kernel.
  # name: outputs.nixosConfigurations.${name}.config.boot.kernelPackages.kernel.system
  name: outputs.nixosConfigurations.${name}.config.boot.kernelPackages != null
)
