# Deployment notes

This repository records this host's deployment configuration. Each entry records one deployment
change.

2026-09-02: the backend moved to v9.9.7 (`localhost/backend:aaa111`). The engine was rebuilt; model
assets were unchanged.

2026-09-20: the container memory limit rose from 64 GiB to 72 GiB for the pre-save free-space check.
