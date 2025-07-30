{ config, ... }:
{
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
            group_by = [ "host" ];
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
