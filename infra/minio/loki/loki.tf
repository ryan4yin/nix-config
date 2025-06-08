# ==============================================
# Buckets
# ==============================================

resource "minio_s3_bucket" "k3s-test-1-loki-chunks" {
  bucket = "k3s-test-1-loki-chunks"
  acl    = "private"
}

# ==============================================
# Bucket Lifecycle
# ==============================================

resource "minio_ilm_policy" "loki-chunks-expire-rules" {
  bucket = minio_s3_bucket.k3s-test-1-loki-chunks.bucket

  rule {
    id         = "expire-7d"
    status     = "Enabled"
    expiration = "7d"
  }
}

# ==============================================
# User & Permission
# ==============================================


resource "minio_iam_user" "loki" {
  name          = "loki"
  force_destroy = true
  tags = {
    env       = "prod"
    managedBy = "terraform"
  }
}

resource "minio_iam_service_account" "loki" {
  target_user = minio_iam_user.loki.name
}

resource "minio_iam_policy" "loki" {
  name   = "loki"
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
      "Resource": [
        "arn:aws:s3:::k3s-test-1-loki-chunks/*"
      ]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "loki-1" {
  user_name   = minio_iam_user.loki.id
  policy_name = minio_iam_policy.loki.id
}

# ======================================================

output "loki-chunks_url" {
  value = minio_s3_bucket.k3s-test-1-loki-chunks.bucket_domain_name
}

output "loki_accesskey" {
  value = minio_iam_service_account.loki.access_key
}

output "loki_secretkey" {
  value     = minio_iam_service_account.loki.secret_key
  sensitive = true
}
