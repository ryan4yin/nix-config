{
  lib,
  outputs,
}:
let
  aqua = outputs.nixosConfigurations.aquamarine.config;
in
{
  v2rayExporter = aqua.services.prometheus.exporters.v2ray.listenAddress;
  pgExporter = aqua.services.prometheus.exporters.postgres.listenAddress;
  sftpgoTelemetry = aqua.services.sftpgo.settings.telemetry.bind_address;
}
