
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_security_group" "vpc" {
  name   = "${var.name}-vpc"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-vpc"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "vpc-ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.vpc.id

  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [data.aws_vpc.vpc.cidr_block]
}

resource "aws_security_group_rule" "vpc-ingress-ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.vpc.id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.vpc.cidr_block]
}

resource "aws_security_group_rule" "vpc-egress-all" {
  type              = "egress"
  security_group_id = aws_security_group.vpc.id

  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpc-ingress-transit-gateway" {
  count             = length(var.transit_gateway_destination_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.vpc.id

  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = var.transit_gateway_destination_cidr_blocks
}

resource "aws_security_group_rule" "vpc-egress-transit-gateway" {
  count             = length(var.transit_gateway_destination_cidr_blocks) > 0 ? 1 : 0
  type              = "egress"
  security_group_id = aws_security_group.vpc.id

  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = var.transit_gateway_destination_cidr_blocks
}

resource "aws_security_group" "web" {
  name   = "${var.name}-web"
  vpc_id = var.vpc_id


  tags = {
    Name = "${var.name}-web"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "web-ingress-80" {
  type              = "ingress"
  security_group_id = aws_security_group.web.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web-ingress-443" {
  type              = "ingress"
  security_group_id = aws_security_group.web.id

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

