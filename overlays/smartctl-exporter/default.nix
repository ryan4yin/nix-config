# smartctl_exporter 0.14.0 derives `Describe()` from the devices it can read at
# startup, so when a device only becomes readable later (an NVMe whose ACL
# arrives late, or an HDD waking from standby) `Collect()` emits metrics whose
# descriptors were never registered and `/metrics` returns HTTP 500, failing the
# whole scrape and hiding even the healthy disks.
#
# Pin the package to the upstream commit that carries the fix (PR #329, merged
# 2026-09-28, then included in the "Update Go (#391)" commit below) instead of
# backporting it as a patch. Drop this overlay once nixpkgs provides a version
# containing the #329 fix:
#   https://github.com/prometheus-community/smartctl_exporter/pull/329
_: _final: prev: {
  prometheus-smartctl-exporter = prev.prometheus-smartctl-exporter.overrideAttrs (_prev: {
    version = "0.14.0-unstable-2026-09-28";
    src = prev.fetchFromGitHub {
      owner = "prometheus-community";
      repo = "smartctl_exporter";
      rev = "6274decc61212cc61e58796cc3b8cf5cfa035809";
      hash = "sha256-KR+j4uLqxVtRpQ7L8UxOypOHZG9CxUGw0ELIO7e6tXc=";
    };
    vendorHash = "sha256-PJiMYWdoQ3Zk7sYHveG9uIgOjllgPuu6RjAPVdKUi6Y=";
  });
}
