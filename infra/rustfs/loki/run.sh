# Credentials for the RustFS S3 endpoint (used both for the S3 backend and the
# AWS provider):
#
# export AWS_ACCESS_KEY_ID="xxx"
# export AWS_SECRET_ACCESS_KEY="xxx"
#
# If the buckets already exist (carried over from MinIO by the S3-level copy),
# import them first so terraform adopts them instead of failing:
#   terraform import aws_s3_bucket.loki-chunks k3s-test-1-loki-chunks
#   terraform import aws_s3_bucket.loki-ruler  k3s-test-1-loki-ruler
#   terraform import aws_s3_bucket.loki-admin  k3s-test-1-loki-admin
#
terraform init -reconfigure
terraform plan
terraform apply
