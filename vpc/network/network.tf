resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-gw"
  }
}

module "nats" {
  source            = "./nat"
  name              = "${var.name}-nat"
  azs               = var.azs
  public_subnet_ids = module.public_subnets.ids
}

module "public_subnets" {
  source              = "./public_subnet"
  name                = "${var.name}-public"
  vpc_id              = var.vpc_id
  cidrs               = var.public_subnets
  azs                 = var.azs
  internet_gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route53_zone" "private" {
  name = "${var.name}.private"
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_security_group" "sg" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg-ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.sg.id

  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [var.vpc_cidr]
}

resource "aws_security_group_rule" "sg-ingress-ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.sg.id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [var.vpc_cidr]
}

resource "aws_security_group_rule" "sg-egress" {
  type              = "egress"
  security_group_id = aws_security_group.sg.id

  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "transit-gateway-ingress" {
  count             = length(var.transit_gateway_destination_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.sg.id

  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = var.transit_gateway_destination_cidr_blocks
}

resource "aws_security_group_rule" "transit-gateway-egress" {
  count             = length(var.transit_gateway_destination_cidr_blocks) > 0 ? 1 : 0
  type              = "egress"
  security_group_id = aws_security_group.sg.id

  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = var.transit_gateway_destination_cidr_blocks
}