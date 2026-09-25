terraform {
  # https://developer.hashicorp.com/terraform/language/settings/backends/s3#credentials-and-shared-configuration
  backend "s3" {
    bucket = "tf-s3-backend"
    key    = "homelab/rustfs/terraform.tfstate"
    region = "us-east-1"
    endpoints = {
      s3 = "https://s3.writefor.fun"
    }

    # pass access key & secret via:
    # 1. env: AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
    # 2. aws credential: ~/.aws/credentials
    # access_key = ""
    # secret_key = ""

    # RustFS is S3-compatible but not AWS, so skip AWS-specific validation.
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Buckets/lifecycle go through the AWS provider pointed at the RustFS S3
# endpoint; the Loki IAM user is created with `rc` (see ../README.md).
provider "aws" {
  region = "us-east-1"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "https://s3.writefor.fun"
  }
}
