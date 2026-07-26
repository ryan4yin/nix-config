{
  lib,
  myvars,
  ...
}:
let
  # Hosts that should not be scraped:
  # - powered-off machines (SBCs and the whole k3s-prod-1 cluster), to avoid TargetDown
  #   noise; remove entries from this list when the machines come back online.
  # - shoukei (a laptop on untrusted networks), its node-exporter is disabled on the
  #   machine itself, so there is nothing to scrape.
  offlineHosts = [
    "shoukei"
    "suzu"
    "suzi"
    "yukina"
    "nozomi"
    "chiaya"
    "rakushun"
    "mitsuha"
    "k3s-prod-1-master-1"
    "k3s-prod-1-master-2"
    "k3s-prod-1-master-3"
    "k3s-prod-1-worker-1"
    "k3s-prod-1-worker-2"
    "k3s-prod-1-worker-3"
  ];
in
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
          job_name = "nut-exporter-homelab-ups";
          scrape_interval = "30s";
          metrics_path = "/ups_metrics";
          params.ups = [ "homelab" ];
          static_configs = [
            {
              targets = [ "${myvars.networking.hostsAddr.kubevirt-shushou.ipv4}:9199" ];
              labels.type = "app";
              labels.app = "nut";
              labels.host = "kubevirt-shushou";
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
