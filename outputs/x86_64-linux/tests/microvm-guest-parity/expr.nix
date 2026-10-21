{
  lib,
  outputs,
}:
# A VM host must run each guest from its `nixosConfigurations` entry, the system
# `just microvm-deploy` ships, instead of a second evaluation on the host. Only
# the wiring is checked here: reading the guest's own options would force its
# full configuration, which needs the private secrets input CI cannot fetch.
let
  inherit (outputs) nixosConfigurations;
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
      guest: vm:
      lib.nameValuePair "${host}/${guest}" (
        if vm.evaluatedConfig == null then
          "no evaluatedConfig"
        else
          vm.evaluatedConfig.config.networking.hostName
      )
    ) nixosConfigurations.${host}.config.microvm.vms
  ) vmHosts
)
