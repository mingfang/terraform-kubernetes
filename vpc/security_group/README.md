
# Module `vpc/security_group`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `name` (required)
* `transit_gateway_destination_cidr_blocks` (default `[]`)
* `vpc_id` (required)

## Output Values
* `security-group-vpc`
* `security-group-web`

## Managed Resources
* `aws_security_group.vpc` from `aws`
* `aws_security_group.web` from `aws`
* `aws_security_group_rule.vpc-egress-all` from `aws`
* `aws_security_group_rule.vpc-egress-transit-gateway` from `aws`
* `aws_security_group_rule.vpc-ingress` from `aws`
* `aws_security_group_rule.vpc-ingress-ssh` from `aws`
* `aws_security_group_rule.vpc-ingress-transit-gateway` from `aws`
* `aws_security_group_rule.web-ingress-443` from `aws`
* `aws_security_group_rule.web-ingress-80` from `aws`

## Data Resources
* `data.aws_vpc.vpc` from `aws`

