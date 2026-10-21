# Monitoring & Alerting

## Alert Rules & Recording Rules

- [awesome-prometheus-alerts](https://github.com/samber/awesome-prometheus-alerts)
  - Collection of Prometheus alerting rules.
- [victoria-metrics-k8s-stack/files/rules](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack/files/rules/generated)
  - Alert Rules & Recording Rules used by kube-prometheus-stack.

## Backup Freshness

`modules/nixos/base/restic-backup.nix` writes `restic_backup_last_success_timestamp_seconds` to
node_exporter's textfile collector after a successful run. `alert_rules/restic-backup.yml` alerts
when it is older than two days (the schedule is daily) or absent entirely.

## TODO

- **Dead-man switch**: `Watchdog` in `alert_rules/general.yml` always fires (`vector(1)`) but is
  routed to the `null` receiver in `alert.nix`, so a dead alerting pipeline looks identical to a
  healthy one. Route it to an external heartbeat service (healthchecks.io, Uptime Kuma, PagerDuty
  DeadMansSnitch) that notifies when the heartbeat stops, or run an out-of-band probe against
  Alertmanager.
