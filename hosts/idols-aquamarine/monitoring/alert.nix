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
      # https://docs.victoriametrics.com/victoriametrics/vmalert/#link-to-alert-source
      # Set this two args to generate the correct `.GeneratorURL`
      "external.url" = "https://grafana.writefor.fun";
      "external.alert.source" =
        ''explore?left={"datasource":"{{ if eq .Type \"vlogs\" }}VictoriaLogs{{ else }}VictoriaMetrics{{ end }}","queries":[{"expr":{{ .Expr|jsonEscape|queryEscape }},"refId":"A"}],"range":{"from":"{{ .ActiveAt.UnixMilli }}","to":"now"}}'';
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
            group_wait = "3m"; # wait for other alerts to "group by" before send notification
            group_interval = "5m"; # wait for an interval, before send a new alert in the same group
            repeat_interval = "5h"; # avoiding repeating reminders too frequently
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
              # Telegram's MarkdownV2 & Markdown are all very painful, we use html instead.
              # https://core.telegram.org/bots/api#formatting-options
              parse_mode = "HTML";
              # Message template
              message = ''
                {{- if eq .Status "firing" }}
                🟡 <b>告警触发</b>  {{ .CommonLabels.alertname }} [{{ index .CommonLabels "severity" | title }}]
                {{- else }}
                🟢 <b>告警恢复</b>  {{ .CommonLabels.alertname }} [{{ index .CommonLabels "severity" | title }}]
                {{- end }}

                {{- range .Alerts }}

                📊 <b>详情:</b>
                • <b>告警组</b>: {{ .Labels.alertgroup }}
                • <b>等级</b>: {{ if eq .Labels.severity "critical" }}🔴{{ else }}🟡 {{ end }} {{ .Labels.severity | title }}
                • <b>查询</b>: <a href="{{ .GeneratorURL }}">Grafana Explore</a>
                • <b>触发值</b>: {{ with .Annotations.value }}{{ . }}{{ else }}N/A{{ end }}
                • <b>Env</b>: {{ with .Labels.env }}{{ . }}{{ else }}N/A{{ end }}
                • <b>Cluster</b>: {{ with .Labels.cluster }}{{ . }}{{ else }}N/A{{ end }}
                • <b>Namespace</b>: {{ with .Labels.namespace }}{{ . }}{{ else }}N/A{{ end }}
                • <b>标签</b>: {{ range .Labels.SortedPairs }}{{ .Name }}={{ .Value }},{{ end }}
                • <b>触发时间</b>: {{ .StartsAt.Format "2006-01-02 15:04:05" }}
                {{- end }}
              '';
            }
          ];
        }
      ];
    };
  };
}
