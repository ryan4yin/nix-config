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

## HTTPS Probes

`blackbox.nix` probes every named caddy vhost on youko over HTTPS; `alert_rules/blackbox.yml` alerts
on a failing probe and on a certificate that expires within 14 days.

## Deploy State

Physical hosts also publish, from `modules/nixos/base/monitoring.nix`:

- `node_reboot_required`, for `HostRequiresReboot` in `alert_rules/node-exporter.yml`.
- `flake_input_last_modified{input,rev}` of the running generation, for
  `alert_rules/flake-inputs.yml`: nixpkgs older than 30 days, or a week behind the newest host.

## TODO

- **Dead-man switch**: `Watchdog` in `alert_rules/general.yml` always fires (`vector(1)`) but is
  routed to the `null` receiver in `alert.nix`, so a dead alerting pipeline looks identical to a
  healthy one. Route it to an external heartbeat service (healthchecks.io, Uptime Kuma, PagerDuty
  DeadMansSnitch) that notifies when the heartbeat stops, or run an out-of-band probe against
  Alertmanager.
