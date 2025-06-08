# for provider
#
# export MINIO_PASSWORD="xxx"

# for terraform's s3 backend
#
# export AWS_ACCESS_KEY_ID="xxx"
# export AWS_SECRET_ACCESS_KEY="xxx"
#
terraform init
terraform plan
terraform apply

# show secret key
terraform output loki_secretkey

