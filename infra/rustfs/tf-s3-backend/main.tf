terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Buckets/lifecycle go through the AWS provider pointed at the RustFS S3
# endpoint; IAM users/policies are created with `rc` (see ../README.md).
#
# Credentials come from the environment: AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY.
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
