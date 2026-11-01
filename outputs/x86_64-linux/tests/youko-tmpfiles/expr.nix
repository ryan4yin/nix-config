{
  lib,
  outputs,
  ...
}:
let
  unit = outputs.nixosConfigurations.youko.config.systemd.services.systemd-tmpfiles-setup;
in
{
  requiresMountsFor = builtins.sort builtins.lessThan unit.unitConfig.RequiresMountsFor;
}
