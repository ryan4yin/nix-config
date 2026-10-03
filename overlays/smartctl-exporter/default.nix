# smartctl_exporter 0.14.0 derives `Describe()` from the devices it can read at
# startup, so when a device only becomes readable later (an NVMe whose ACL
# arrives late, or an HDD waking from standby) `Collect()` emits metrics whose
# descriptors were never registered and `/metrics` starts returning HTTP 500,
# which fails the whole scrape and hides even the healthy disks.
#
# Backport of upstream PR #329: `Describe()` now sends the full, explicit
# descriptor set. Drop this overlay once smartctl_exporter 0.15.0 is released
# and packaged in nixpkgs:
#   https://github.com/prometheus-community/smartctl_exporter/pull/329
_: _final: prev: {
  prometheus-smartctl-exporter = prev.prometheus-smartctl-exporter.overrideAttrs (prevAttrs: {
    patches = (prevAttrs.patches or [ ]) ++ [ ./329-explicit-descriptors.patch ];
  });
}
