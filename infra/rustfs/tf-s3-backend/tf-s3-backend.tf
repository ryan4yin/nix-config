# https://developer.hashicorp.com/terraform/language/settings/backends/s3
#
# Only the bucket is managed here. The IAM service account that terraform uses
# to read/write state is created with `rc` (see ../README.md); its keys are
# exported as AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY before running terraform.
resource "aws_s3_bucket" "tf-s3-backend" {
  bucket = "tf-s3-backend"

  lifecycle {
    prevent_destroy = true
  }
}
