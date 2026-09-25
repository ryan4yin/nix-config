# Credentials for the RustFS S3 endpoint: the RustFS root credentials, or a
# dedicated account limited to this bucket (see ../README.md):
#
# export AWS_ACCESS_KEY_ID="xxx"
# export AWS_SECRET_ACCESS_KEY="xxx"
#
# If the bucket already exists (carried over from MinIO by the S3-level copy),
# import it first so terraform adopts it instead of failing to recreate it:
#   terraform import aws_s3_bucket.tf-s3-backend tf-s3-backend
#
terraform init
terraform plan
terraform apply
