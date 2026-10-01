{
  lib,
  outputs,
  ...
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (_: {
  userHasDockerAccess = false;
  userHasPodmanAccess = false;
  userHasDiskAccess = false;
  userHasKvmAccess = false;
  userHasInputAccess = false;
})
