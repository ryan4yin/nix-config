{
  lib,
  config,
  myvars,
  ...
}: {
  # Workaround for prometheus to store data in another place
  systemd.tmpfiles.rules = [
    "D /data/apps/prometheus2 0751 prometheus prometheus - -"
    "L+ /var/lib/prometheus2 - - - - /data/apps/prometheus2"
  ];

  # https://prometheus.io/docs/prometheus/latest/configuration/configuration/
  services.prometheus = {
    enable = true;
    checkConfig = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    webExternalUrl = "http://prometheus.writefor.fun";

    extraFlags = [
      "--storage.tsdb.retention.time=30d"
      # https://prometheus.io/docs/prometheus/latest/storage/#remote-storage-integrations
      "--web.enable-remote-write-receiver"
    ];
    # Directory below /var/lib to store Prometheus metrics data.
    stateDir = "prometheus2";

    # Reload prometheus when configuration file changes (instead of restart).
    enableReload = true;
    # https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_read
    # remoteRead = [];

    # Rules are read from these files.
    # https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/
    #
    # Prometheus supports two types of rules which may be configured
    # and then evaluated at regular intervals:
    #   1. Recording rules
    #      Recording rules allow you to precompute frequently needed or computationally
    #      expensive expressions and save their result as a new set of time series.
    #      Querying the precomputed result will then often be much faster than executing the original expression.
    #      This is especially useful for dashboards, which need to query the same expression repeatedly every time they refresh.
    #   2. Alerting rules
    #      Alerting rules allow you to define alert conditions based on Prometheus expression language expressions
    #      and to send notifications about firing alerts to an external service.
    ruleFiles = [
      ./alert_rules/node-exporter.yml
      ./alert_rules/kubestate-exporter.yml
      ./alert_rules/etcd_embedded-exporter.yml
      ./alert_rules/istio_embedded-exporter.yml
      ./alert_rules/coredns_embedded-exporter.yml

      # ./recording_rules.yml
    ];

    # specifies a set of targets and parameters describing how to scrape metrics from them.
    # https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config
    scrapeConfigs =
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

    # specifies Alertmanager instances the Prometheus server sends alerts to
    # https://prometheus.io/docs/prometheus/latest/configuration/configuration/#alertmanager_config
    alertmanagers = [{static_configs = [{targets = ["localhost:9093"];}];}];
  };

  services.prometheus.alertmanager = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9093;
    webExternalUrl = "http://alertmanager.writefor.fun";
    logLevel = "info";

    environmentFile = config.age.secrets."alertmanager.env".path;
    configuration = {
      global = {
        # The smarthost and SMTP sender used for mail notifications.
        smtp_smarthost = "smtp.qq.com:465";
        smtp_from = "$SMTP_SENDER_EMAIL";
        smtp_auth_username = "$SMTP_AUTH_USERNAME";
        smtp_auth_password = "$SMTP_AUTH_PASSWORD";
        # smtp.qq.com:465 support SSL only, so we need to disable TLS here.
        # https://service.mail.qq.com/detail/0/310
        smtp_require_tls = false;
      };
      route = {
        receiver = "default";
        routes = [
          {
            group_by = ["host"];
            group_wait = "5m";
            group_interval = "5m";
            repeat_interval = "4h";
            receiver = "default";
          }
        ];
      };
      receivers = [
        {
          name = "default";
          email_configs = [
            {
              to = "ryan4yin@linux.com";
              # Whether to notify about resolved alerts.
              send_resolved = true;
            }
          ];
        }
      ];
    };
  };
}
