{
  lib,
  myvars,
  ...
}:
{
  # Since victoriametrics use DynamicUser, the user & group do not exists before the service starts.
  # this group is used as a supplementary Unix group for the service to access our data dir(/data/apps/xxx)
  users.groups.victoriametrics-data = { };

  # Workaround for victoriametrics to store data in another place
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  systemd.tmpfiles.rules = [
    "d /data/apps/victoriametrics 0770 root victoriametrics-data - -"
  ];

  # Symlinks do not work with DynamicUser, so we should use bind mount here.
  # https://github.com/systemd/systemd/issues/25097#issuecomment-1929074961
  systemd.services.victoriametrics.serviceConfig = {
    SupplementaryGroups = [ "victoriametrics-data" ];
    BindPaths = [ "/data/apps/victoriametrics:/var/lib/victoriametrics:rbind" ];
  };

  # https://victoriametrics.io/docs/victoriametrics/latest/configuration/configuration/
  services.victoriametrics = {
    enable = true;
    listenAddress = "127.0.0.1:9090";
    retentionPeriod = "30d";

    extraOptions = [
      # Allowed percent of system memory VictoriaMetrics caches may occupy.
      "-memory.allowedPercent=50"
    ];
    # Directory below /var/lib to store victoriametrics metrics data.
    stateDir = "victoriametrics";

    # specifies a set of targets and parameters describing how to scrape metrics from them.
    # https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config
    prometheusConfig = {
      scrape_configs = [
        # --- Homelab Applications --- #

        {
          job_name = "dnsmasq-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "${myvars.networking.hostsAddr.suzi.ipv4}:9153" ];
              labels.type = "app";
              labels.app = "dnsmasq";
              labels.host = "suzi";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }

        {
          job_name = "v2ray-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "${myvars.networking.hostsAddr.aquamarine.ipv4}:9153" ];
              labels.type = "app";
              labels.app = "v2ray";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
        {
          job_name = "postgres-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "${myvars.networking.hostsAddr.aquamarine.ipv4}:9187" ];
              labels.type = "app";
              labels.app = "postgresql";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
        {
          job_name = "sftpgo-embedded-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "${myvars.networking.hostsAddr.aquamarine.ipv4}:10000" ];
              labels.type = "app";
              labels.app = "sftpgo";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
        {
          job_name = "alertmanager-embedded-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "localhost:9093" ];
              labels.type = "app";
              labels.app = "alertmanager";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
        {
          job_name = "victoriametrics-embedded-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              # scrape vm itself
              targets = [ "localhost:9090" ];
              labels.type = "app";
              labels.app = "victoriametrics";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
      ]
      # --- Hosts --- #
      ++ (lib.attrsets.foldlAttrs (
        acc: hostname: addr:
        acc
        ++ [
          {
            job_name = "node-exporter-${hostname}";
            scrape_interval = "30s";
            metrics_path = "/metrics";
            static_configs = [
              {
                # All my NixOS hosts.
                targets = [ "${addr.ipv4}:9100" ];
                labels.type = "node";
                labels.host = hostname;
                labels.env = "homelab";
                labels.cluster = "homelab";
              }
            ];
          }
        ]
      ) [ ] myvars.networking.hostsAddr);
    };
  };
}
