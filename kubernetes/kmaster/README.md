
# Module `kubernetes/kmaster`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `cluster_name` (required)
* `efs_dns_name` (required)
* `environments` (default `[]`): Docker daemon conf
* `image_id` (required)
* `insecure_registry` (default `null`): Docker daemon conf
* `instance_type` (required)
* `key_name` (required)
* `lb_private_fqdn` (required): private Route53 name
* `lb_public_fqdn` (required): public Route53 name
* `name` (required)
* `security_group_ids` (default `[]`): add EFS security group
* `subnet_ids` (required)
* `target_group_arns` (required): LB target_group_arns
* `use_spot` (default `false`)
* `vpc_id` (required)

## Output Values
* `kubeconfig_bucket`
* `security_group_id`
* `subnet_ids`

## Managed Resources
* `aws_autoscaling_group.asg` from `aws`
* `aws_iam_instance_profile.instance_profile` from `aws`
* `aws_iam_role.iam_role` from `aws`
* `aws_iam_role_policy.role_policy` from `aws`
* `aws_launch_template.this` from `aws`
* `aws_s3_bucket.keys` from `aws`
* `aws_s3_bucket_public_access_block.keys` from `aws`
* `aws_security_group.sg` from `aws`

## Data Resources
* `data.aws_vpc.vpc` from `aws`

