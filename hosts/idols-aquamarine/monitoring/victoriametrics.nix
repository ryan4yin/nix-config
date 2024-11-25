{
  lib,
  myvars,
  ...
}: {
  # Since victoriametrics use DynamicUser, the user & group do not exists before the service starts.
  # this group is used as a supplementary Unix group for the service to access our data dir(/data/apps/xxx)
  users.groups.victoriametrics-data = {};

  # Workaround for victoriametrics to store data in another place
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  systemd.tmpfiles.rules = [
    "d /data/apps/victoriametrics 0770 root victoriametrics-data - -"
  ];

  # Symlinks do not work with DynamicUser, so we should use bind mount here.
  # https://github.com/systemd/systemd/issues/25097#issuecomment-1929074961
  systemd.services.victoriametrics.serviceConfig = {
    SupplementaryGroups = ["victoriametrics-data"];
    BindPaths = ["/data/apps/victoriametrics:/var/lib/victoriametrics:rbind"];
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
      scrape_configs =
        [
          # --- Homelab Applications --- #

          {
            job_name = "dnsmasq-exporter";
            scrape_interval = "30s";
            metrics_path = "/metrics";
            static_configs = [
              {
                targets = ["${myvars.networking.hostsAddr.suzi.ipv4}:9153"];
                labels.type = "app";
                labels.app = "dnsmasq";
                labels.host = "suzi";
              }
            ];
          }

          {
            job_name = "v2ray-exporter";
            scrape_interval = "30s";
            metrics_path = "/metrics";
            static_configs = [
              {
                targets = ["${myvars.networking.hostsAddr.aquamarine.ipv4}:9153"];
                labels.type = "app";
                labels.app = "v2ray";
                labels.host = "aquamarine";
              }
            ];
          }
          {
            job_name = "postgres-exporter";
            scrape_interval = "30s";
            metrics_path = "/metrics";
            static_configs = [
              {
                targets = ["${myvars.networking.hostsAddr.aquamarine.ipv4}:9187"];
                labels.type = "app";
                labels.app = "postgresql";
                labels.host = "aquamarine";
              }
            ];
          }
          {
            job_name = "sftpgo-embedded-exporter";
            scrape_interval = "30s";
            metrics_path = "/metrics";
            static_configs = [
              {
                targets = ["${myvars.networking.hostsAddr.aquamarine.ipv4}:10000"];
                labels.type = "app";
                labels.app = "sftpgo";
                labels.host = "aquamarine";
              }
            ];
          }
        ]
        # --- Hosts --- #
        ++ (
          lib.attrsets.foldlAttrs
          (acc: hostname: addr:
            acc
            ++ [
              {
                job_name = "node-exporter-${hostname}";
                scrape_interval = "30s";
                metrics_path = "/metrics";
                static_configs = [
                  {
                    # All my NixOS hosts.
                    targets = ["${addr.ipv4}:9100"];
                    labels.type = "node";
                    labels.host = hostname;
                  }
                ];
              }
            ])
          []
          myvars.networking.hostsAddr
        );
    };
  };

  services.vmalert = {
    enable = true;
    settings = {
      "datasource.url" = "http://localhost:9090";
      "notifier.url" = ["http://localhost:9093"]; # alertmanager's api

      # Whether to disable long-lived connections to the datasource.
      "datasource.disableKeepAlive" = true;
      # Whether to avoid stripping sensitive information such as auth headers or passwords
      # from URLs in log messages or UI and exported metrics.
      "datasource.showURL" = false;
      rule = [
        ./alert_rules/node-exporter.yml
        ./alert_rules/kubestate-exporter.yml
        ./alert_rules/etcd_embedded-exporter.yml
        ./alert_rules/istio_embedded-exporter.yml
        ./alert_rules/coredns_embedded-exporter.yml
      ];
    };
  };
}
