{
  config,
  myvars,
  ...
}: {
  services.grafana = {
    enable = true;
    dataDir = "/var/lib/grafana";
    # DeclarativePlugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel ];
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3351;
        protocol = "http";
        domain = "grafana.writefo.fun";
        # Redirect to correct domain if the host header does not match the domain. Prevents DNS rebinding attacks.
        serve_from_sub_path = false;
        # Add subpath to the root_url if serve_from_sub_path is true
        root_url = "%(protocol)s://%(domain)s:%(http_port)s/";
        enforce_domain = false;
        read_timeout = "180s";
        # Enable HTTP compression, this can improve transfer speed and bandwidth utilization.
        enable_gzip = true;
        # Cdn for accelerating loading of frontend assets.
        # cdn_url = "https://cdn.jsdelivr.net/npm/grafana@7.5.5";
      };

      security = {
        admin_user = myvars.username;
        admin_email = myvars.useremail;
        # Use file provider to read the admin password from a file.
        # https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#file-provider
        admin_password = "$__file{${config.age.secrets."grafana-admin-password".path}}";
      };
      users = {
        allow_sign_up = false;
        # home_page = "";
        default_theme = "dark";
      };
    };

    # Declaratively provision Grafana's data sources, dashboards, and alerting rules.
    # Grafana's alerting rules is not recommended to use, we use Prometheus alertmanager instead.
    # https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources
    provision = {
      datasources.path = ./datasources.yml;
      dashboards.path = ./dashboards.yml;
    };
  };

  environment.etc."grafana/dashboards".source = ./dashboards;
}
