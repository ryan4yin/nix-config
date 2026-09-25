# Buckets for Grafana Loki

Stores log data in RustFS (S3-compatible) at `s3.writefor.fun`.

Managed here: the `chunks`, `ruler`, and `admin` buckets.

Not managed here:

- The Loki IAM user and its policy. Create the user with the official `rc` client instead.
- The 7-day expiry on `chunks`. The AWS provider's lifecycle resource waits on a response RustFS
  does not satisfy; use `rc ilm rule add rustfs/k3s-test-1-loki-chunks --expiry-days 7`.

See `../README.md` for both.
