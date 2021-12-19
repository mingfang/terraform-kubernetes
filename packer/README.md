
# Module `packer`

Provider Requirements:
* **null:** (any version)

## Input Variables
* `AWS_SHARED_CREDENTIALS_FILE` (required)
* `ami_name` (required)
* `region` (required)
* `subnet_id` (required)
* `vpc_id` (required)

## Output Values
* `ami_name`

## Managed Resources
* `null_resource.packer` from `null`

