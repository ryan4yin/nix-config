terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "2.5.0"
    }
  }
}

# https://registry.terraform.io/providers/aminueza/minio/latest/docs
provider "minio" {
  minio_server = "minio.writefor.fun"
  minio_user   = "ryan"

  minio_api_version = "v4"
  minio_region      = "us-east-1"
  minio_ssl         = true
}
