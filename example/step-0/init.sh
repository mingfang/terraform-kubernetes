# Create S3 bucket and DynamoDB locking table for Terraform S3 Backend

# initialize backend

terraform init
terraform apply

# save state to backend

terraform init -force-copy
rm *.tfstate* || true