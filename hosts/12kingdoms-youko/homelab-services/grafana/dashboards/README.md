# Grafana Dashboards

## Homelab

1. https://grafana.com/grafana/dashboards/1860-node-exporter-full/
2. https://grafana.com/grafana/dashboards/9578-alertmanager/
3. `smartctl.json` — drive/SSD SMART health (wear, spare, media errors, temperature). Custom, built
   on the `smartctl_exporter` metrics.
4. `gpu.json` — GPU utilization, VRAM, and temperature.
5. `nut-exporter.json` — UPS status (battery, load, runtime) from the NUT exporter.
6. `power.json` — Aquamarine's CPU package/core/uncore power from the node_exporter RAPL collector,
   plus GPU power from hwmon. This is silicon power, not wall power.
7. `power-overview.json` — **Homelab Power**: all physical hosts' known CPU + GPU power, with a
   stacked-by-host area chart and a per-host line chart. The UPS load panel is whole-rack only; this
   is still silicon power, not per-host wall power.

## Kubernetes

1. https://github.com/dotdc/grafana-dashboards-kubernetes/

## Istio

1. https://github.com/istio/istio/tree/1.23.0/manifests/addons/dashboards

## Loki Mixin

An opinionated set of dashboards, alerts, and recording rules to monitor your Loki cluster. The
mixin provides a comprehensive package for monitoring Loki in production.

1. https://github.com/grafana/loki/tree/main/production/loki-mixin-compiled/dashboards

## Databases

1. PostgreSQL: https://grafana.com/grafana/dashboards/9628-postgresql-database/
   - Requires Prometheus PostgreSQL exporter metrics. See:
     <https://github.com/prometheus-community/postgres_exporter>
1. CloudNative-PG:
   - Instance:
     https://github.com/cloudnative-pg/grafana-dashboards/blob/main/charts/cluster/grafana-dashboard.json
   - Pooler(PGBouncer): https://github.com/cloudnative-pg/grafana-dashboards/issues/7

## VictoriaMetrics

- https://grafana.com/orgs/victoriametrics/dashboards
