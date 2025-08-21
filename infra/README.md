# Infrastructure as Code

This directory contains Infrastructure as Code (IaC) configurations using Terraform, primarily for
managing storage and backend services.

## Current Structure

```
infra/
├── README.md
└── minio/                    # MinIO S3-compatible storage configurations
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

### MinIO Storage

- **Loki Buckets**: Dedicated storage for Grafana Loki log aggregation
- **Terraform Backend**: Centralized state management for all Terraform configurations

### External Resources

- **Kubernetes YAML**: Managed in separate repository
  [ryan4yin/k8s-gitops](https://github.com/ryan4yin/k8s-gitops)
- **Secrets Management**: Handled via agenix in [../secrets](../secrets/)

## Usage

Each subdirectory contains its own Terraform configuration:

1. **Navigate to specific service**:

   ```bash
   cd infra/minio/loki
   ```

2. **Deploy configuration**:

   ```bash
   ./run.sh
   ```

3. **Manual deployment**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Security Considerations

- All storage buckets are configured with appropriate access policies
- State files are encrypted at rest
- Access credentials are managed through environment variables
- Network access is restricted to necessary hosts only
