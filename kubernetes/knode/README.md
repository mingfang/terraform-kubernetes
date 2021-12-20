
# Module `kubernetes/knode`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `cluster_name` (required)
* `environments` (default `[]`)
* `image_id` (required)
* `insecure_registry` (default `null`)
* `instance_type` (required)
* `key_name` (required)
* `kmaster` (required)
* `max_size` (default `null`)
* `min_size` (default `null`)
* `name` (required)
* `nat_ids` (required)
* `on_demand_base_capacity` (default `null`): Setting on_demand_base_capacity < size would result in (size - on_demand_base_capacity) spot instances; null == no spot
* `security_group_ids` (default `[]`): add EFS security group
* `size` (default `0`)
* `subnet_ids` (required)
* `taints` (default `""`)
* `target_group_arns` (default `[]`): ALB target_group_arns
* `transit_gateway_destination_cidr_blocks` (default `[]`)
* `transit_gateway_id` (default `null`)
* `volume_size` (required)
* `vpc_id` (required)
* `zone` (required)

## Output Values
* `instance_type`
* `launch_template`
* `size`
* `zone`

## Managed Resources
* `aws_autoscaling_group.asg` from `aws`
* `aws_iam_instance_profile.instance_profile` from `aws`
* `aws_iam_role.iam_role` from `aws`
* `aws_iam_role_policy.role_policy` from `aws`
* `aws_launch_template.this` from `aws`

## Data Resources
* `data.aws_vpc.vpc` from `aws`

