{
  lib,
  myvars,
  ...
}:
let
  # Powered-off hosts (SBCs) plus shoukei (exporter disabled on the
  # machine); remove entries when they come back online.
  offlineHosts = [
    "shoukei"
    "suzu"
    "suzi"
    "yukina"
    "nozomi"
    "chiaya"
    "rakushun"
    "mitsuha"
  ];
in
{
  # Since victoriametrics use DynamicUser, the user & group do not exists before the service starts.
  # this group is used as a supplementary Unix group for the service to access our data dir under /var/lib
  users.groups.victoriametrics-data = { };

  # Workaround for victoriametrics to store data in another place
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  systemd.tmpfiles.rules = [
    "d /var/lib/victoriametrics 0770 root victoriametrics-data - -"
  ];

  # Symlinks do not work with DynamicUser, so we should use bind mount here.
  # https://github.com/systemd/systemd/issues/25097#issuecomment-1929074961
  systemd.services.victoriametrics.serviceConfig = {
    SupplementaryGroups = [ "victoriametrics-data" ];
  };

  # https://victoriametrics.io/docs/victoriametrics/latest/configuration/configuration/
  services.victoriametrics = {
    enable = true;
    listenAddress = "127.0.0.1:9090";
    retentionPeriod = "30d";

    extraOptions = [
      # Allowed percent of system memory VictoriaMetrics caches may occupy.
      "-memory.allowedPercent=50"
      # Deduplicate samples with the same timestamp within one scrape interval
      # (e.g. from vmagent retries/HA replicas). Without this the storage rejects
      # them with "duplicate sample for timestamp; overrides not allowed".
      # Keep it >= the senders' scrapeInterval (vmagent 20s, in-cluster 30s).
      "-dedup.minScrapeInterval=30s"
    ];
    # Directory below /var/lib to store victoriametrics metrics data.
    stateDir = "victoriametrics";

    # specifies a set of targets and parameters describing how to scrape metrics from them.
    # https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config
    prometheusConfig = {
      scrape_configs = [
        # --- Homelab Applications --- #

        # suzi is powered off, disable scraping until it comes back online.
        /*
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
        */

        {
          job_name = "restic-rest-server";
          scrape_interval = "60s";
          metrics_path = "/metrics";
          static_configs = [
            {
              # same-host rest-server bound to loopback (127.0.0.1:8000)
              targets = [ "127.0.0.1:8000" ];
              labels.type = "app";
              labels.app = "restic";
              labels.host = "youko";
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
              # same-host exporter bound to loopback (127.0.0.1:9153)
              targets = [ "127.0.0.1:9153" ];
              labels.type = "app";
              labels.app = "v2ray";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
        {
          job_name = "nut-exporter-homelab-ups";
          scrape_interval = "30s";
          metrics_path = "/ups_metrics";
          params.ups = [ "homelab" ];
          static_configs = [
            {
              targets = [ "${myvars.networking.hostsAddr.shushou.ipv4}:9199" ];
              labels.type = "app";
              labels.app = "nut";
              labels.host = "shushou";
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
              # same-host exporter bound to loopback (127.0.0.1:9187)
              targets = [ "127.0.0.1:9187" ];
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
              # same-host exporter bound to loopback (127.0.0.1:10000)
              targets = [ "127.0.0.1:10000" ];
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
        {
          job_name = "immich-api";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              # same-host exporter bound to all interfaces (127.0.0.1:8081)
              targets = [ "127.0.0.1:8081" ];
              labels.type = "app";
              labels.app = "immich";
              labels.host = "youko";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
        {
          job_name = "immich-microservices";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              # same-host exporter bound to all interfaces (127.0.0.1:8082)
              targets = [ "127.0.0.1:8082" ];
              labels.type = "app";
              labels.app = "immich";
              labels.host = "youko";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
      ]
      # --- Hosts --- #
      ++ (lib.attrsets.foldlAttrs
        (
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
        )
        [ ]
        (lib.attrsets.filterAttrs (n: _: !(builtins.elem n offlineHosts)) myvars.networking.hostsAddr)
      );
    };
  };
}
