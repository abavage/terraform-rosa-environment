terraform init \
terraform plan -auto-approve \
cp backend/backend.tf . 

### enables backend to use s3
terraform init -auto-approve
