# Create S3 bucket and DynamoDB locking table for Terraform S3 Backend

1 - Must create the S3 bucket before initialing the backend.
```shell script
mv backend.tf backend.tf.save
terraform init
terraform apply
```

2- initialize backend
```shell script
mv backend.tf.save backend.tf
terraform init -force-copy
rm *.tfstate*
```

3- copy the backend.tf to the other steps. MUST CHANGE THE KEY FIELD


