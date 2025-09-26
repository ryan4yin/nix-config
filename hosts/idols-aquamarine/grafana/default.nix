{
  pkgs,
  config,
  myvars,
  ...
}:
{

  imports = [
    ./dashboards.nix
    ./datasources.nix
  ];

  services.grafana = {
    enable = true;
    dataDir = "/data/apps/grafana";
    provision.enable = true;
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

    # https://github.com/NixOS/nixpkgs/tree/master/pkgs/servers/monitoring/grafana/plugins
    declarativePlugins = with pkgs.grafanaPlugins; [
      # https://github.com/VictoriaMetrics/victoriametrics-datasource
      # supports victoria-metrics's MetricsQL, template, tracing, prettify, etc.
      victoriametrics-metrics-datasource
      # https://github.com/VictoriaMetrics/victorialogs-datasource
      victoriametrics-logs-datasource

      redis-app
      redis-datasource
      redis-explorer-app

      grafana-googlesheets-datasource
      grafana-github-datasource
      grafana-clickhouse-datasource
      grafana-mqtt-datasource
      frser-sqlite-datasource

      # https://github.com/grafana/grafana-infinity-datasource
      # Visualize data from JSON, CSV, XML, GraphQL and HTML endpoints in Grafana
      yesoreyeram-infinity-datasource

      # plugins not included in nixpkgs: trino, grafana advisor, llm, kafka
    ];
  };

  environment.etc."grafana/dashboards".source = ./dashboards;
}
