{
  lib,
  outputs,
  ...
}:
let
  builderHosts = [
    "ai-niri"
    "shoryu"
    "shushou"
    "youko"
  ];
  cfg = name: outputs.nixosConfigurations.${name}.config;
  usesAquamarine =
    name:
    builtins.any (machine: machine.hostName == "aquamarine" && machine.sshUser == "root")
      (cfg name).nix.buildMachines;
in
{
  distributedBuilds = lib.genAttrs builderHosts (name: (cfg name).nix.distributedBuilds);
  aquamarineConfigured = lib.genAttrs builderHosts usesAquamarine;
  # The builder must advertise only its native platform: an aarch64 build there
  # runs under qemu-user and loses to building it on the client.
  builderSystems = lib.genAttrs builderHosts (
    name: map (machine: machine.systems) (cfg name).nix.buildMachines
  );
}
