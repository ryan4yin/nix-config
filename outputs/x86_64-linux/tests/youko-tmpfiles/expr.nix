{
  outputs,
  ...
}:
let
  services = outputs.nixosConfigurations.youko.config.systemd.services;
  unit = services.data-tmpfiles;
in
{
  wantsMountsFor = builtins.sort builtins.lessThan unit.unitConfig.WantsMountsFor;
  execStart = unit.serviceConfig.ExecStart;
  setupWaitsForData =
    (services.systemd-tmpfiles-setup or { }).unitConfig.RequiresMountsFor or [ ] != [ ];
}
