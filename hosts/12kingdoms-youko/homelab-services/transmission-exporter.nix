{
  config,
  pkgs,
  myvars,
  ...
}:
let
  script = pkgs.writeText "transmission-exporter.py" (builtins.readFile ./transmission-exporter.py);
in
{
  # There is no transmission exporter in nixpkgs, so expose a small set of
  # gauges from the authenticated RPC on loopback for VictoriaMetrics.
  systemd.services.transmission-exporter = {
    description = "Prometheus exporter for the transmission RPC";
    wantedBy = [ "multi-user.target" ];
    after = [ "transmission.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${script}";
      Restart = "on-failure";
      RestartSec = "10s";
      DynamicUser = true;
      # The RPC password lives only in the agenix credentials file; hand it to
      # the dynamic user through a systemd credential instead of widening the
      # file's permissions.
      LoadCredential = "transmission-rpc:${config.age.secrets."transmission-credentials.json".path}";
      Environment = [
        "TRANSMISSION_RPC_URL=http://192.168.5.118:9091/transmission/rpc"
        "TRANSMISSION_RPC_USER=${myvars.username}"
        "TRANSMISSION_EXPORTER_LISTEN=127.0.0.1:9555"
      ];
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      IPAddressDeny = [ "any" ];
      IPAddressAllow = [
        "localhost"
        "192.168.5.118"
      ];
    };
  };
}
