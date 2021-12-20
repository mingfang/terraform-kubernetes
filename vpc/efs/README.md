
# Module `vpc/efs`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `dns_name` (required)
* `name` (required)
* `performance_mode` (default `"generalPurpose"`)
* `provisioned_throughput_in_mibps` (default `null`)
* `region` (required)
* `route53_zone_id` (required)
* `subnet_ids` (required)
* `transition_to_ia` (default `"AFTER_7_DAYS"`)
* `vpc_id` (required)

## Output Values
* `mount_target_client_security_group_id`
* `private_fqdn`
* `this`

## Managed Resources
* `aws_efs_file_system.efs` from `aws`
* `aws_efs_mount_target.target` from `aws`
* `aws_route53_record.efs` from `aws`
* `aws_security_group.mount_target` from `aws`
* `aws_security_group.mount_target_client` from `aws`
* `aws_security_group_rule.efs_egress` from `aws`
* `aws_security_group_rule.efs_ingress` from `aws`

## Data Resources
* `data.aws_vpc.vpc` from `aws`

