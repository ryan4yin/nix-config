# Monitoring & Alerting

## Alert Rules & Recoding Rules

- [awesome-prometheus-alerts](https://github.com/samber/awesome-prometheus-alerts)
  - Collection of Prometheus alerting rules.
- [victoria-metrics-k8s-stack/files/rules](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack/files/rules/generated)
  - Alert Rules & Recoding Rules used by kube-prometheus-stack.

## TODO

- **Dead-man switch**: `Watchdog` in `alert_rules/general.yml` always fires (`vector(1)`) but is
  routed to the `null` receiver in `alert.nix`, so a dead alerting pipeline looks identical to a
  healthy one. Route it to an external heartbeat service (healthchecks.io, Uptime Kuma, PagerDuty
  DeadMansSnitch) that notifies when the heartbeat stops, or run an out-of-band probe against
  Alertmanager.
- **Backup freshness**: nothing alerts on "no recent successful backup". The systemd `failed` state
  only catches crashes, not a job that never ran or a backup that is silently stale. Export the last
  successful backup timestamp (restic prometheus exporter; btrfs snapshot time via the node-exporter
  textfile collector) and alert when it exceeds the SLO, and add an off-host btrbk `target` so local
  snapshots are not the only copy.
