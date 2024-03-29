/* Access STS using private network */
data "aws_vpc_endpoint_service" "sts" {
  service = "sts"
}
resource "aws_vpc_endpoint" "sts" {
  vpc_id              = local.vpc_id
  service_name        = data.aws_vpc_endpoint_service.sts.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = local.security_group_ids
  subnet_ids          = local.private_subnet_ids
  private_dns_enabled = true

  tags = {
    Name = "${var.cluster_name}-${data.aws_vpc_endpoint_service.sts.service_name}"
  }
}
