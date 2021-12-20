
# Module `vpc/network/private_subnet`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `azs` (required)
* `cidrs` (required)
* `enable` (default `true`)
* `name` (required)
* `nat_gateway_ids` (default `[]`)
* `tags` (default `{}`)
* `transit_gateway_destination_cidr_blocks` (default `[]`)
* `transit_gateway_id` (default `null`)
* `vpc_id` (required)

## Output Values
* `ids`

## Managed Resources
* `aws_route.nat` from `aws`
* `aws_route.transit_gateway` from `aws`
* `aws_route_table.route_tables` from `aws`
* `aws_route_table_association.route_association` from `aws`
* `aws_subnet.subnets` from `aws`

