{ config, lib, ... }:
{
  services.vmalert = {
    enable = true;
    settings = {
      "httpListenAddr" = "127.0.0.1:8880";

      "datasource.url" = "http://localhost:9090";
      "notifier.url" = [ "http://localhost:9093" ]; # alertmanager's api

      # Whether to disable long-lived connections to the datasource.
      "datasource.disableKeepAlive" = true;
      # Whether to avoid stripping sensitive information such as auth headers or passwords
      # from URLs in log messages or UI and exported metrics.
      "datasource.showURL" = false;
      # Path to the files with alerting and/or recording rules.
      rule = [
        "${./alert_rules}/*.yml"
      ];
    };
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
        receiver = "telegram";
        routes = [
          {
            receiver = "telegram";
            # group alerts by labels
            group_by = [
              "job"
              # --- Alert labels ---
              "alertname"
              "alertgroup"
              # --- kubernetes labels ---
              "namespace"
              "service"
              # --- custom labels ---
              "cluster"
              "env"
              "type"
              "host"
            ];
            group_wait = "5m";
            group_interval = "5m";
            repeat_interval = "4h";
          }
          # {
          #   # Route only prod env's critical alerts to email (most severe alerts)
          #   match = {
          #     severity = "critical";
          #     env = "prd";
          #   };
          #   receiver = "email";
          #   group_by = [
          #     "host"
          #     "namespace"
          #     "pod"
          #     "job"
          #   ];
          #   group_wait = "1m";
          #   group_interval = "5m";
          #   repeat_interval = "2h";
          # }
        ];
      };
      receivers = [
        # {
        #   name = "email";
        #   email_configs = [
        #     {
        #       to = "ryan4yin@linux.com";
        #       # Whether to notify about resolved alerts.
        #       send_resolved = true;
        #     }
        #   ];
        # }
        {
          name = "telegram";
          telegram_configs = [
            {
              bot_token = "$TELEGRAM_BOT_TOKEN";
              chat_id = 586169186; # My Telegram ID
              # Whether to notify about resolved alerts.
              send_resolved = true;
              # Disable notifications for resolved alerts
              disable_notifications = false;
              # Parse mode for the message
              parse_mode = "Markdown";
              # Message template
              message = ''
                *Alert:* {{ .GroupLabels.alertname }}
                *Status:* {{ .Status }}
                *Severity:* {{ .CommonLabels.severity }}
                {{ if .GroupLabels.namespace }}*Namespace:* {{ .GroupLabels.namespace }}{{ end }}
                {{ if .GroupLabels.pod }}*Pod:* {{ .GroupLabels.pod }}{{ end }}
                {{ if .GroupLabels.job }}*Job:* {{ .GroupLabels.job }}{{ end }}
                {{ if .GroupLabels.host }}*Host:* {{ .GroupLabels.host }}{{ end }}

                {{ range .Alerts }}
                *Alert:* {{ .Annotations.summary }}
                *Description:* {{ .Annotations.description }}
                {{ if .Labels.instance }}*Instance:* {{ .Labels.instance }}{{ end }}
                {{ if .Labels.container }}*Container:* {{ .Labels.container }}{{ end }}
                *Started:* {{ .StartsAt.Format "2006-01-02 15:04:05" }}
                {{ if .EndsAt }}
                *Ended:* {{ .EndsAt.Format "2006-01-02 15:04:05" }}
                {{ end }}
                {{ end }}
              '';
            }
          ];
        }
      ];
    };
  };
}
