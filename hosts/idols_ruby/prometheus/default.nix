{
  config,
  vars_networking,
  ...
}: {
  # https://prometheus.io/docs/prometheus/latest/configuration/configuration/
  services.prometheus = {
    enable = true;
    checkConfig = true;
    listenAddress = "0.0.0.0";
    port = 9090;
    webExternalUrl = "https://prometheus.writefor.fun";

    extraFlags = ["--storage.tsdb.retention.time=15d"];
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
      ./recording_rules.yml
      ./alerting_rules.yml
    ];

    # specifies a set of targets and parameters describing how to scrape metrics from them.
    # https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config
    scrapeConfigs = [
      {
        job_name = "node-exporter";
        scrape_interval = "30s";
        metrics_path = "/metrics";
        static_configs = [
          {
            # All my NixOS hosts.
            targets =
              map (host: "${host.address}:9100")
              (builtins.attrValues vars_networking.hostAddress);
            labels.type = "node";
          }
        ];
      }
    ];

    # specifies Alertmanager instances the Prometheus server sends alerts to
    # https://prometheus.io/docs/prometheus/latest/configuration/configuration/#alertmanager_config
    alertmanagers = [{static_configs = [{targets = ["localhost:9093"];}];}];
  };

  services.prometheus.alertmanager = {
    enable = true;
    logLevel = "info";
    environmentFile = config.age.secrets."alertmanager.env".path;
    webExternalUrl = "https://alertmanager.writefor.fun";
    listenAddress = "[::1]";
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
