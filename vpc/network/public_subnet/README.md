
# Module `vpc/network/public_subnet`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `azs` (required)
* `cidrs` (required)
* `internet_gateway_id` (default `""`)
* `name` (required)
* `vpc_id` (required)

## Output Values
* `ids`

## Managed Resources
* `aws_route_table.route_table` from `aws`
* `aws_route_table_association.route_association` from `aws`
* `aws_subnet.subnets` from `aws`

