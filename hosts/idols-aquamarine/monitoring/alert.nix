{ config, ... }:
{
  # https://docs.victoriametrics.com/victoriametrics/vmalert/
  services.vmalert.instances."homelab" = {
    enable = true;
    settings = {
      "httpListenAddr" = "127.0.0.1:8880";

      "datasource.url" = "http://localhost:9090";
      "notifier.url" = [ "http://localhost:9093" ]; # alertmanager's api
      # Recording rules results are persisted via remote write.
      "remoteWrite.url" = "http://localhost:9090";
      "remoteRead.url" = "http://localhost:9090";

      # Whether to disable long-lived connections to the datasource.
      "datasource.disableKeepAlive" = true;
      # Whether to avoid stripping sensitive information such as auth headers or passwords
      # from URLs in log messages or UI and exported metrics.
      "datasource.showURL" = false;
      # Path to the files with alerting and/or recording rules.
      rule = [
        "${./alert_rules}/*.yml"
        "${./recoding_rules}/*.yml"
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
            # Watchdog & InfoInhibitor are meta alerts that should never notify,
            # route them to a null receiver.
            receiver = "null";
            matchers = [ ''severity = "none"'' ];
          }
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
              # --- custom labels ---
              "cluster"
              "env"
              "type"
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
        {
          # Discards all notifications (for meta alerts that should never notify).
          name = "null";
        }
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
              # Telegram limits a message to 4096 chars, so only render the first 5 alerts
              # in a group and keep the fields minimal (no full label dump).
              #
              # WARNING: never use template variables ($i, $a, ...) here. The NixOS
              # alertmanager module pipes the generated config through `envsubst`
              # (to inject $TELEGRAM_BOT_TOKEN etc.), which silently replaces any
              # $var in this template with an empty string and breaks rendering at
              # notify time. Use `{{ range .Alerts }}` + dot, and `define`/`template`
              # for reuse instead.
              message = ''
                {{- if eq .Status "firing" }}
                🟡 <b>告警触发</b> [{{ .CommonLabels.severity | title }}] <b>{{ .CommonLabels.alertname }}</b> (共 {{ len .Alerts }} 条)
                {{- else }}
                🟢 <b>告警恢复</b> [{{ .CommonLabels.severity | title }}] <b>{{ .CommonLabels.alertname }}</b>
                {{- end }}

                • <b>告警组</b>: {{ .CommonLabels.alertgroup }}
                • <b>Cluster</b>: {{ with .CommonLabels.cluster }}{{ . }}{{ else }}N/A{{ end }}
                • <b>Env</b>: {{ with .CommonLabels.env }}{{ . }}{{ else }}N/A{{ end }}
                • <b>Namespace</b>: {{ with .CommonLabels.namespace }}{{ . }}{{ else }}N/A{{ end }}
                {{- define "alert" }}

                ━━━━━━━━
                📌 {{ with .Annotations.summary }}<b>{{ . }}</b>{{ else }}<b>{{ .Labels.instance }}</b>{{ end }}
                {{- with .Labels.nodename }}
                🏠 {{ . }}
                {{- end }}
                🔗 <a href="{{ .GeneratorURL }}">Grafana Explore</a> · ⏱ {{ .StartsAt.Format "2006-01-02 15:04:05" }}
                {{- end }}
                {{- if le (len .Alerts) 5 }}
                {{- range .Alerts }}{{ template "alert" . }}
                {{- end }}
                {{- else }}
                {{- range slice .Alerts 0 5 }}{{ template "alert" . }}
                {{- end }}

                ⚠️ 另有 {{ len (slice .Alerts 5) }} 条同组告警未列出，请查看 Alertmanager。
                {{- end }}
              '';
            }
          ];
        }
      ];
    };
  };
}
