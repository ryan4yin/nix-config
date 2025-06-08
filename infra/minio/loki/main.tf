terraform {
  # https://developer.hashicorp.com/terraform/language/settings/backends/s3#credentials-and-shared-configuration
  backend "s3" {
    bucket = "tf-s3-backend"
    key    = "homelab/minio/terraform.tfstate"
    region = "us-east-1"
    endpoints = {
      s3 = "https://minio.writefor.fun"
    }

    # pass access key & secret via:
    # 1. env: AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
    # 2. aws credential: ~/.aws/credentials
    # access_key = ""
    # secret_key = ""

    # we're using minio, skip all aws related validation & checks
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.5.2"
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
