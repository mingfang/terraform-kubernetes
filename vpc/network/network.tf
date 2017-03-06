# Variables

variable "name" {}

variable "vpc_id" {}

variable "vpc_cidr" {}

variable "azs" {
  type = "list"
}

variable "public_subnets" {
  type = "list"
}

variable "com_subnets" {
  type = "list"
}

variable "green_subnets" {
  type = "list"
}

variable "net_subnets" {
  type = "list"
}

variable "admin_subnets" {
  type = "list"
}

variable "kmaster_subnets" {
  type = "list"
}

# Resources

resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}-gw"
  }
}

module "public_subnets" {
  source = "./public_subnet"

  name                = "${var.name}-public"
  vpc_id              = "${var.vpc_id}"
  cidrs               = "${var.public_subnets}"
  azs                 = "${var.azs}"
  internet_gateway_id = "${aws_internet_gateway.gw.id}"
}

module "nats" {
  source = "./nat"

  name              = "${var.name}-nat"
  azs               = "${var.azs}"
  public_subnet_ids = "${module.public_subnets.ids}"
}

module "com_subnets" {
  source = "./private_subnet"

  name            = "${var.name}-com"
  cidrs           = "${var.com_subnets}"
  vpc_id          = "${var.vpc_id}"
  azs             = "${var.azs}"
  nat_gateway_ids = "${module.nats.ids}"
}

module "green_subnets" {
  source = "./private_subnet"

  name            = "${var.name}-green"
  cidrs           = "${var.green_subnets}"
  vpc_id          = "${var.vpc_id}"
  azs             = "${var.azs}"
  nat_gateway_ids = "${module.nats.ids}"
}

module "net_subnets" {
  source = "./private_subnet"

  name            = "${var.name}-net"
  cidrs           = "${var.net_subnets}"
  vpc_id          = "${var.vpc_id}"
  azs             = "${var.azs}"
  nat_gateway_ids = "${module.nats.ids}"
}

module "admin_subnets" {
  source = "./private_subnet"

  name   = "${var.name}-admin"
  cidrs  = "${var.admin_subnets}"
  vpc_id = "${var.vpc_id}"
  azs    = "${var.azs}"

  nat_gateway_ids = "${module.nats.ids}"
}

//todo: public for testing; make private
module "kmaster_subnets" {
  //  source = "./private_subnet"
  source = "./public_subnet"

  name   = "${var.name}-kmaster"
  cidrs  = "${var.kmaster_subnets}"
  vpc_id = "${var.vpc_id}"
  azs    = "${var.azs}"

  //  nat_gateway_ids = "${module.nats.nat_gateway_ids}"
  internet_gateway_id = "${aws_internet_gateway.gw.id}"
}

resource "aws_network_acl" "acl" {
  vpc_id = "${var.vpc_id}"

  subnet_ids = [
    "${concat(module.public_subnets.ids, module.com_subnets.ids, module.green_subnets.ids, module.net_subnets.ids, module.admin_subnets.ids, module.kmaster_subnets.ids)}",
  ]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "${var.name}-all"
  }
}

resource "aws_route53_zone" "private" {
  name   = "local"
  vpc_id = "${var.vpc_id}"
}

# Output

output "public_subnet_ids" {
  value = "${module.public_subnets.ids}"
}

output "kmaster_subnet_ids" {
  value = "${module.kmaster_subnets.ids}"
}

output "green_subnet_ids" {
  value = "${module.green_subnets.ids}"
}

output "net_subnet_ids" {
  value = "${module.net_subnets.ids}"
}

output "com_subnet_ids" {
  value = "${module.com_subnets.ids}"
}

output "nat_gateway_ids" {
  value = "${module.nats.ids}"
}

output "route53_private_id" {
  value = "${aws_route53_zone.private.id}"
}
