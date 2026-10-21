{
  lib,
  outputs,
}:
let
  vmHosts = [
    "shoryu"
    "shushou"
    "youko"
  ];
in
lib.mergeAttrsList (
  map (
    host:
    lib.mapAttrs' (
      guest: _: lib.nameValuePair "${host}/${guest}" true
    ) outputs.nixosConfigurations.${host}.config.microvm.vms
  ) vmHosts
)
