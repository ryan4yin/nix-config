# Worker node notes — edge-worker-04

## Disk layout

The data volume moved from `/dev/nvme1n1p1` to the LVM volume `/dev/mapper/vg0-edge` in the
2026-08-19 rebuild. The mount stays `/var/lib/edge` on ext4.

## Background

The metrics-server on the same cluster crash-looped 112 times between 2026-08-20 and 2026-08-24.
That is why the rebuild notes are thin: I was firefighting the metrics-server for four days and did
not write anything down.

## Memory temperature

The DIMM temperature sensor on channel B stopped reporting between 2026-08-21 and 2026-08-24. The
dashboard kept showing a cached 78 °C reading through that window, so the value is not a live
measurement and cannot establish the peak for those days. Outside that window the sensor reports
normally.

## Current values

| Field           | Value           |
| --------------- | --------------- |
| Mount           | `/var/lib/edge` |
| Filesystem      | ext4            |
| Backup interval | 6 hours         |
