/* Access EC2 using private network */
data "aws_vpc_endpoint_service" "ec2" {
  service = "ec2"
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = local.vpc_id
  service_name        = data.aws_vpc_endpoint_service.ec2.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = local.security_group_ids
  subnet_ids          = local.private_subnet_ids
  private_dns_enabled = true

  tags = {
    Name = "${var.cluster_name}-${data.aws_vpc_endpoint_service.ec2.service_name}"
  }
}
