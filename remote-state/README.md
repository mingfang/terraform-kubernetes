
# Module `remote-state`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `name` (required): unique state name; will automatically append -terraform-state

## Output Values
* `dynamodb`
* `s3`

## Managed Resources
* `aws_dynamodb_table.terraform_locks` from `aws`
* `aws_s3_bucket.terraform_state` from `aws`
* `aws_s3_bucket_public_access_block.terraform_state` from `aws`

