# https://developer.hashicorp.com/terraform/language/settings/backends/s3
resource "minio_s3_bucket" "tf-s3-backend" {
  bucket = "tf-s3-backend"
  acl    = "private"
}

resource "minio_iam_user" "tf-s3-backend" {
  name          = "tf-s3-backend"
  force_destroy = true
  tags = {
    env       = "prod"
    managedBy = "terraform"
  }
}

resource "minio_iam_policy" "tf-s3-backend" {
  name   = "tf-s3-backend"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::tf-s3-backend"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::tf-s3-backend/*"
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "tf-s3-backend-1" {
  user_name   = minio_iam_user.tf-s3-backend.id
  policy_name = minio_iam_policy.tf-s3-backend.id
}

resource "minio_iam_service_account" "tf-s3-backend" {
  target_user = minio_iam_user.tf-s3-backend.name
}


# ======================================================

output "tf-s3-backend_id" {
  value = minio_s3_bucket.tf-s3-backend.id
}

output "tf-s3-backend_url" {
  value = minio_s3_bucket.tf-s3-backend.bucket_domain_name
}

output "tf-s3-backend_accesskey" {
  value = minio_iam_service_account.tf-s3-backend.access_key
}

output "tf-s3-backend_secretkey" {
  value     = minio_iam_service_account.tf-s3-backend.secret_key
  sensitive = true
}
