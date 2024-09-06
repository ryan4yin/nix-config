resource "minio_s3_bucket" "openobserve" {
  bucket = "openobserve"
  acl    = "private"
}

resource "minio_iam_user" "openobserve" {
  name          = "openobserve"
  force_destroy = true
  tags = {
    env       = "prod"
    managedBy = "terraform"
  }
}

resource "minio_iam_policy" "openobserve" {
  name   = "openobserve"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid": "ObjectFullAccess",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::openobserve/*"
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "openobserve-1" {
  user_name   = minio_iam_user.openobserve.id
  policy_name = minio_iam_policy.openobserve.id
}

resource "minio_iam_service_account" "openobserve" {
  target_user = minio_iam_user.openobserve.name
}


# ======================================================

output "openobserve_id" {
  value = minio_s3_bucket.openobserve.id
}

output "openobserve_url" {
  value = minio_s3_bucket.openobserve.bucket_domain_name
}

output "openobserve_accesskey" {
  value = minio_iam_service_account.openobserve.access_key
}

output "openobserve_secretkey" {
  value     = minio_iam_service_account.openobserve.secret_key
  sensitive = true
}
