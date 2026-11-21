{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.exporters.blackbox;

  # Unauthenticated probes count as failed logins and trip transmission's
  # anti-brute-force lockout, so its RPC port is probed over TCP instead.
  httpsExcluded = [ "transmission.writefor.fun" ];

  # Every named caddy vhost on this host; the `*.writefor.fun` catch-all only
  # answers 404.
  httpsTargets = map (name: "https://${name}/") (
    lib.filter (name: !lib.hasPrefix "*." name && !lib.elem name httpsExcluded) (
      lib.attrNames config.services.caddy.virtualHosts
    )
  );

  relabelToExporter = [
    {
      source_labels = [ "__address__" ];
      target_label = "__param_target";
    }
    {
      source_labels = [ "__param_target" ];
      target_label = "instance";
    }
    {
      target_label = "__address__";
      replacement = "127.0.0.1:${toString cfg.port}";
    }
  ];
in
{
  # https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md
  services.prometheus.exporters.blackbox = {
    enable = true;
    listenAddress = "127.0.0.1";
    configFile = (pkgs.formats.yaml { }).generate "blackbox.yml" {
      modules.https_up = {
        prober = "http";
        timeout = "10s";
        http = {
          # The services resolve to this host's LAN IPv4.
          preferred_ip_protocol = "ip4";
          ip_protocol_fallback = false;
          fail_if_not_ssl = true;
          # 401/403 come from the backend's own auth (restic, s3, webdav),
          # so caddy and the service are both up.
          valid_status_codes = [
            200
            401
            403
          ];
        };
      };
      modules.tcp_up = {
        prober = "tcp";
        timeout = "10s";
      };
    };
  };

  services.victoriametrics.prometheusConfig.scrape_configs = [
    {
      job_name = "blackbox-https";
      scrape_interval = "60s";
      metrics_path = "/probe";
      params.module = [ "https_up" ];
      static_configs = [
        {
          targets = httpsTargets;
          labels.type = "probe";
          labels.app = "caddy";
          labels.host = "youko";
          labels.env = "homelab";
          labels.cluster = "homelab";
        }
      ];
      relabel_configs = relabelToExporter;
    }
    {
      job_name = "blackbox-tcp";
      scrape_interval = "60s";
      metrics_path = "/probe";
      params.module = [ "tcp_up" ];
      static_configs = [
        {
          targets = [ "192.168.5.118:9091" ];
          labels.type = "probe";
          labels.app = "transmission";
          labels.host = "youko";
          labels.env = "homelab";
          labels.cluster = "homelab";
        }
      ];
      relabel_configs = relabelToExporter;
    }
  ];
}
