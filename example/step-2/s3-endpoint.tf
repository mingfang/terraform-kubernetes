/* Access S3 using private network */

data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = local.vpc_id
  service_name = data.aws_vpc_endpoint_service.s3.service_name
  tags = {
    Name = "${var.cluster_name}-${data.aws_vpc_endpoint_service.s3.service_name}"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  route_table_id  = local.vpc_main_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
