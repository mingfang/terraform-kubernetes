
# Module `example/step-0`

Provider Requirements:
* **aws:** (any version)
* **local:** (any version)

## Input Variables
* `azs` (required)
* `cluster_name` (required): the name of this cluster
* `region` (required): choose your region

## Output Values
* `azs`
* `cluster_name`
* `region`

## Managed Resources
* `aws_dynamodb_table.terraform_locks` from `aws`
* `aws_s3_bucket.terraform_state` from `aws`
* `aws_s3_bucket_public_access_block.terraform_state` from `aws`
* `local_file.step-0-tfvars` from `local`
* `local_file.step-0-variables` from `local`
* `local_file.step-N-backend` from `local`

