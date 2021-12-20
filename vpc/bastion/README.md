
# Module `vpc/bastion`

Provider Requirements:
* **aws:** (any version)
* **template:** (any version)

## Input Variables
* `associate_public_ip_address` (default `true`)
* `enable` (default `true`)
* `image_id` (required)
* `instance_type` (default `"t2.micro"`)
* `key_name` (required)
* `name` (required)
* `route53_zone_id` (required)
* `subnet_id` (required)
* `vpc_id` (required)

## Output Values
* `fqdn`

## Managed Resources
* `aws_instance.bastion` from `aws`
* `aws_route53_record.bastion` from `aws`
* `aws_security_group.bastion` from `aws`

## Data Resources
* `data.aws_vpc.vpc` from `aws`
* `data.template_file.start` from `template`

