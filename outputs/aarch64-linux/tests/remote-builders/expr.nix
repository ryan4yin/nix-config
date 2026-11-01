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
}
