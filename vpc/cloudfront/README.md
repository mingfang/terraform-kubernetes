
# Module `vpc/cloudfront`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `aliases` (required)
* `certificate_arn` (default `""`)
* `origin_domain_name` (required)

## Output Values
* `aws_cloudfront_distribution`

## Managed Resources
* `aws_cloudfront_distribution.web` from `aws`

