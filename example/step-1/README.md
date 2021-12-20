
# Module `example/step-1`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `azs` (required)
* `cluster_name` (required): the name of this cluster
* `name` (required): the name of this cluster
* `public_domain` (required): you public domain, e.g. example.com
* `region` (required): choose your region

## Managed Resources
* `aws_route53_record.public` from `aws`
* `aws_route53_zone.public` from `aws`

## Data Resources
* `data.aws_route53_zone.legionx-com` from `aws`

## Child Modules
* `com_cert` from [../../vpc/certificate](../../vpc/certificate)

