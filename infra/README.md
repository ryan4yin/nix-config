# Infrastructure as Code

This directory contains Infrastructure as Code (IaC) configurations using Terraform, primarily for
managing storage and backend services.

## Current Structure

```
infra/
├── README.md
└── rustfs/                   # RustFS S3-compatible storage (replaced MinIO)
    ├── README.md             # RustFS + rc runbook (buckets / IAM)
    ├── loki/                 # Loki log storage buckets
    │   ├── README.md
    │   ├── loki.tf          # Loki-specific bucket configuration
    │   ├── main.tf          # Main Terraform configuration
    │   └── run.sh           # Deployment script
    └── tf-s3-backend/        # Terraform S3 backend setup
        ├── README.md
        ├── main.tf          # Main configuration
        ├── run.sh           # Deployment script
        └── tf-s3-backend.tf # Backend bucket configuration
```

## Services Overview

### RustFS Storage

- **Loki Buckets**: Dedicated storage for Grafana Loki log aggregation
- **Terraform Backend**: Centralized state management for all Terraform configurations

RustFS speaks the S3 API but not MinIO's Admin API, so buckets are managed with the AWS provider
while lifecycle rules and IAM users/policies use the official `rc` client. See
[rustfs/README.md](./rustfs/README.md).

### External Resources

- **Kubernetes YAML**: Managed in separate repository
  [ryan4yin/k8s-gitops](https://github.com/ryan4yin/k8s-gitops)
- **Secrets Management**: Handled via agenix in [../secrets](../secrets/)

## Usage

Each subdirectory contains its own Terraform configuration:

1. **Navigate to specific service**:

   ```bash
   cd infra/rustfs/loki
   ```

2. **Deploy configuration**:

   ```bash
   bash run.sh
   ```

3. **Manual deployment**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Security Considerations

- Buckets are declared as bare `aws_s3_bucket` resources, with no bucket policy or server-side
  encryption configuration. The only guard in Terraform is `prevent_destroy` on the `tf-s3-backend`
  state bucket.
- IAM users and policies are created by hand with the `rc` client, not Terraform (see
  [rustfs/README.md](./rustfs/README.md)).
- Access credentials are managed through environment variables (`AWS_ACCESS_KEY_ID` /
  `AWS_SECRET_ACCESS_KEY`).
