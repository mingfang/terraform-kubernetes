
# Module `vpc/network`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `azs` (required)
* `name` (required)
* `public_subnets` (required)
* `transit_gateway_destination_cidr_blocks` (default `[]`)
* `vpc_cidr` (required)
* `vpc_id` (required)

## Output Values
* `nat_gateway_ids`
* `nat_gateway_public_ips`
* `public_subnet_ids`
* `route53_private`
* `security_group_id`

## Managed Resources
* `aws_internet_gateway.gw` from `aws`
* `aws_route53_zone.private` from `aws`
* `aws_security_group.sg` from `aws`
* `aws_security_group_rule.sg-egress` from `aws`
* `aws_security_group_rule.sg-ingress` from `aws`
* `aws_security_group_rule.sg-ingress-ssh` from `aws`
* `aws_security_group_rule.transit-gateway-egress` from `aws`
* `aws_security_group_rule.transit-gateway-ingress` from `aws`

## Child Modules
* `nats` from `./nat`
* `public_subnets` from `./public_subnet`

