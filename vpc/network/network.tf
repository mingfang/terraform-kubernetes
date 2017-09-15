# Variables

variable "name" {}

variable "public_domain" {
  default = ""
}

variable "vpc_id" {}

variable "vpc_cidr" {}

variable "azs" {
  type = "list"
}

variable "public_subnets" {
  type = "list"
}

# Resources

resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}-gw"
  }
}

module "nats" {
  source            = "./nat"
  name              = "${var.name}-nat"
  azs               = "${var.azs}"
  public_subnet_ids = "${module.public_subnets.ids}"
}

module "public_subnets" {
  source              = "./public_subnet"
  name                = "${var.name}-public"
  vpc_id              = "${var.vpc_id}"
  cidrs               = "${var.public_subnets}"
  azs                 = "${var.azs}"
  internet_gateway_id = "${aws_internet_gateway.gw.id}"
}

resource "aws_route53_zone" "private" {
  name   = "local"
  vpc_id = "${var.vpc_id}"
}

resource "aws_route53_zone" "public" {
  count = "${length(var.public_domain) > 0 ? 1 : 0}"
  name  = "${var.public_domain}"
}

# Output

output "public_subnet_ids" {
  value = "${module.public_subnets.ids}"
}

output "nat_gateway_ids" {
  value = "${module.nats.ids}"
}

output "route53_private_id" {
  value = "${aws_route53_zone.private.id}"
}

output "route53_public_id" {
  value = "${aws_route53_zone.public.id}"
}
