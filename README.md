terraform init \
terraform plan -auto-approve \
cp backend/backend.tf . 

enables backend to use s3 - the bucket needs to be present for the backend to work \ 
terraform init -auto-approve
