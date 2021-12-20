
# Module `vpc/network/nat`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `azs` (required)
* `name` (default `"nat"`)
* `public_subnet_ids` (required)

## Output Values
* `ids`
* `public_ips`

## Managed Resources
* `aws_eip.nat` from `aws`
* `aws_nat_gateway.nat` from `aws`

