
# Module `vpc/certificate`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `domain_name` (required)
* `enable` (default `true`)
* `subject_alternative_names` (default `[]`)
* `zone_id` (required)

## Output Values
* `arn`

## Managed Resources
* `aws_acm_certificate.cert` from `aws`
* `aws_acm_certificate_validation.cert_validation` from `aws`
* `aws_route53_record.cert_record` from `aws`

