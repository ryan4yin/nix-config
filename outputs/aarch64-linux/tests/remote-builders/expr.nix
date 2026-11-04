{
  outputs,
  ...
}:
let
  name = "shoukei-niri";
  cfg = outputs.nixosConfigurations.${name}.config;
in
{
  distributedBuilds = cfg.nix.distributedBuilds;
  aquamarineConfigured = builtins.any (
    machine: machine.hostName == "aquamarine" && machine.sshUser == "root"
  ) cfg.nix.buildMachines;
  # shoukei builds aarch64 natively, so the builder must not claim it.
  builderSystems = map (machine: machine.systems) cfg.nix.buildMachines;
}
