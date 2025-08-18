# Grafana Dashboards

## Homelab

1. https://grafana.com/grafana/dashboards/1860-node-exporter-full/
2. https://grafana.com/grafana/dashboards/9578-alertmanager/

## Kubernetes

1. https://github.com/dotdc/grafana-dashboards-kubernetes/

## Istio

1. https://github.com/istio/istio/tree/1.23.0/manifests/addons/dashboards

## Kubevirt

1. https://github.com/kubevirt/monitoring/tree/main/dashboards/grafana

## Loki Mixin

An opinionated set of dashboards, alerts, and recording rules to monitor your Loki cluster. The
mixin provides a comprehensive package for monitoring Loki in production.

1. https://github.com/grafana/loki/tree/main/production/loki-mixin-compiled/dashboards

## Databases

1. PostgreSQL: https://grafana.com/grafana/dashboards/9628-postgresql-database/
   - Requires Prometheus PostgreSQL exporter metrics. See: wrouesnel/postgres_exporter
1. CloudNative-PG:
   - Instance:
     https://github.com/cloudnative-pg/grafana-dashboards/blob/main/charts/cluster/grafana-dashboard.json
   - Pooler(PGBouncer): https://github.com/cloudnative-pg/grafana-dashboards/issues/7
