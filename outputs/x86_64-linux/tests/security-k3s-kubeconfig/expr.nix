{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    isK3s = lib.hasPrefix "k3s" name;
    flags = if isK3s then outputs.nixosConfigurations.${name}.config.services.k3s.extraFlags else "";
  in
  {
    mode600 = lib.hasInfix "--write-kubeconfig-mode=600" flags;
    mode644 = lib.hasInfix "--write-kubeconfig-mode=644" flags;
  }
)
