# ==============================================
# Buckets
# ==============================================

resource "aws_s3_bucket" "loki-chunks" {
  bucket = "k3s-test-1-loki-chunks"
}

resource "aws_s3_bucket" "loki-ruler" {
  bucket = "k3s-test-1-loki-ruler"
}

resource "aws_s3_bucket" "loki-admin" {
  bucket = "k3s-test-1-loki-admin"
}

# NOTE: bucket lifecycle is NOT managed here. The AWS provider's
# aws_s3_bucket_lifecycle_configuration waits on a GetBucketLifecycleConfiguration
# response shape that RustFS does not satisfy (it times out). The 7-day expiry on
# `chunks` is set with the official `rc` client instead:
#   rc ilm rule add rustfs/k3s-test-1-loki-chunks --expiry-days 7
# (see ../README.md).
