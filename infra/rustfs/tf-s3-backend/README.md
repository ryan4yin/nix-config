# Terraform's S3 Backend

This terraform workspace is used only once, and we do not save its `terraform.tfstate`.

It creates the `tf-s3-backend` RustFS bucket that stores all the other workspaces' tfstate files.

The IAM service account used to read/write that state is created with the official `rc` client, not
here (RustFS does not implement MinIO's Admin API). See `../README.md` for the `rc` runbook.
