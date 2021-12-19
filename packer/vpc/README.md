
# Module `packer/vpc`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `az` (required)
* `name` (required)
* `region` (required)
* `subnet_cidr` (default `"10.0.0.0/24"`)
* `vpc_cidr` (default `"10.0.0.0/24"`)

## Output Values
* `region`
* `subnet_id`
* `vpc_id`

## Managed Resources
* `aws_internet_gateway.gw` from `aws`
* `aws_route_table.route_table` from `aws`
* `aws_route_table_association.route_association` from `aws`
* `aws_security_group.sg` from `aws`
* `aws_subnet.subnet` from `aws`
* `aws_vpc.vpc` from `aws`

