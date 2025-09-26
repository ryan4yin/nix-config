{ config, ... }:
{

  # Declaratively provision Grafana's data sources, dashboards, and alerting rules.
  # Grafana's alerting rules is not recommended to use, we use Prometheus alertmanager instead.
  # https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources
  services.grafana.provision.datasources.settings = {
    apiVersion = 1;

    # List of data sources to delete from the database.
    deleteDatasources = [
      {
        name = "Loki";
        orgId = 1;
      }
    ];

    # Mark provisioned data sources for deletion if they are no longer in a provisioning file.
    # It takes no effect if data sources are already listed in the deleteDatasources section.
    prune = true;

    datasources = [
      {
        # https://grafana.com/docs/grafana/latest/datasources/prometheus/configure/
        name = "prometheus-homelab";
        type = "prometheus";
        access = "proxy";
        # Access mode - proxy (server in the UI) or direct (browser in the UI).
        url = "http://localhost:9090";
        jsonData = {
          httpMethod = "POST";
          manageAlerts = true;
          timeInterval = "15s";
          queryTimeout = "90s";
          prometheusType = "Prometheus";
          cacheLevel = "High";
          disableRecordingRules = false;
          # As of Grafana 10 the Prometheus data source can be configured to query live dashboards
          # incrementally instead of re-querying the entire duration on each dashboard refresh.
          # Increasing the duration of the incrementalQueryOverlapWindow will increase the size of every incremental query
          # but might be helpful for instances that have inconsistent results for recent data.
          incrementalQueryOverlapWindow = "10m";
        };
        editable = false;
      }
      {
        # The VictoriaMetrics plugin includes more native VM functionality.
        name = "victoriametrics-homelab";
        type = "victoriametrics-metrics-datasource";
        access = "proxy";
        url = "http://localhost:9090";
        # url: http://vmselect:8481/select/0/prometheus  # cluster version
        jsonData = {
          httpMethod = "POST";
          manageAlerts = true;
          timeInterval = "15s";
          queryTimeout = "90s";
          disableMetricsLookup = false; # enable this for metrics autocomplete
          vmuiUrl = "https://prometheus.writefor.fun/vmui/";
        };
        isDefault = true;
        editable = false;
      }
      {
        # https://grafana.com/docs/grafana/latest/datasources/loki/configure-loki-data-source/
        name = "loki-k3s-test-1";
        type = "loki";
        access = "proxy";
        url = "https://loki-gateway.writefor.fun";
        jsonData = {
          timeout = 30;
          maxLines = 1000;
          httpHeaderName1 = "X-Scope-OrgID";
        };
        secureJsonData = {
          httpHeaderValue1 = "fake";
        };
        editable = false;
      }
      {
        name = "alertmanager-homelab";
        type = "alertmanager";
        url = "http://localhost:9093";
        access = "proxy";
        jsonData = {
          implementation = "prometheus";
          handleGrafanaManagedAlerts = false;
        };
        editable = false;
      }
      {
        # https://grafana.com/docs/grafana/latest/datasources/postgres/configure/
        name = "postgres-playground";
        type = "postgres";
        url = "postgres.writefor.fun:5432";
        user = "playground";
        secureJsonData = {
          password = "$__file{${config.age.secrets."grafana-admin-password".path}}";
        };
        jsonData = {
          database = "playground";
          sslmode = "verify-full"; # disable/require/verify-ca/verify-full
          maxOpenConns = 50;
          maxIdleConns = 250;
          maxIdleConnsAuto = true;
          connMaxLifetime = 14400;
          timeInterval = "1m";
          timescaledb = false;
          postgresVersion = 1500; # 15.xx
          # tls
          tlsConfigurationMethod = "file-path";
          sslRootCertFile = ../../../certs/ecc-ca.crt;
        };
        editable = false;
      }
      {
        name = "infinity-dataviewer";
        type = "yesoreyeram-infinity-datasource";
        editable = false;
      }
    ];

  };
}
