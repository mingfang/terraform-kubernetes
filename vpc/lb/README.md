
# Module `vpc/lb`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `dns_names` (default `[]`)
* `idle_timeout` (default `60`)
* `internal` (default `false`)
* `listeners` (default `[]`)
* `load_balancer_type` (default `"application"`)
* `name` (required)
* `route53_zone_id` (required)
* `subnet_ids` (required)
* `vpc_id` (required)

## Output Values
* `fqdn`
* `lb`
* `target_group_arns`

## Managed Resources
* `aws_lb.lb` from `aws`
* `aws_lb_listener.listener` from `aws`
* `aws_lb_target_group.atg` from `aws`
* `aws_route53_record.route53_records` from `aws`
* `aws_security_group.sg` from `aws`
* `aws_security_group_rule.rules` from `aws`

