
# Module `example/step-2`

Provider Requirements:
* **aws:** (any version)

## Input Variables
* `ami_name` (required)
* `azs` (required)
* `bastion_enable` (required)
* `bastion_instance_type` (required)
* `cidr` (required)
* `cluster_name` (required): the name of this cluster
* `com_instance_type` (required)
* `com_size` (required)
* `com_volume_size` (required)
* `efs_provisioned_throughput_in_mibps` (required)
* `efs_transition_to_ia` (required)
* `green_instance_type` (required)
* `green_size` (required)
* `green_volume_size` (required)
* `kmaster_instance_type` (required)
* `name` (required): the name of this cluster
* `private_subnets` (required)
* `public_domain` (required): you public domain, e.g. example.com
* `public_key_path` (required)
* `public_subnets` (required)
* `region` (required): choose your region
* `spot_instance_type` (required)
* `spot_size` (required)
* `spot_volume_size` (required)
* `transit_gateway_destination_cidr_blocks` (required)

## Output Values
* `bastion`

## Managed Resources
* `aws_key_pair.cluster_key_pair` from `aws`
* `aws_network_acl.acl` from `aws`
* `aws_vpc_endpoint.ec2` from `aws`
* `aws_vpc_endpoint.s3` from `aws`
* `aws_vpc_endpoint.sts` from `aws`
* `aws_vpc_endpoint_route_table_association.s3` from `aws`

## Data Resources
* `data.aws_acm_certificate.com_cert` from `aws`
* `data.aws_ami.kubernetes` from `aws`
* `data.aws_route53_zone.public` from `aws`
* `data.aws_vpc_endpoint_service.ec2` from `aws`
* `data.aws_vpc_endpoint_service.s3` from `aws`
* `data.aws_vpc_endpoint_service.sts` from `aws`

## Child Modules
* `bastion` from [../../vpc/bastion](../../vpc/bastion)
* `com_lb` from [../../vpc/lb](../../vpc/lb)
* `com_zone` from [../../kubernetes/knode](../../kubernetes/knode)
* `efs` from [../../vpc/efs](../../vpc/efs)
* `green_zone` from [../../kubernetes/knode](../../kubernetes/knode)
* `kmaster` from [../../kubernetes/kmaster](../../kubernetes/kmaster)
* `kmaster_lb_private` from [../../vpc/lb](../../vpc/lb)
* `kmaster_lb_public` from [../../vpc/lb](../../vpc/lb)
* `network` from [../../vpc/network](../../vpc/network)
* `private_subnets` from [../../vpc/network/private_subnet](../../vpc/network/private_subnet)
* `spot_zone` from [../../kubernetes/knode](../../kubernetes/knode)
* `vpc` from [../../vpc](../../vpc)

