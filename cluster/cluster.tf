# Variables

variable "name" {}

variable "public_domain" {}

variable "access_key" {}

variable "secret_key" {}

variable "public_key_path" {}

variable "region" {}

variable "azs" {
  type = "list"
}

variable "com_size" {
  default = 2
}

variable "green_size" {
  default = 1
}

variable "net_size" {
  default = 1
}

variable "db_size" {
  default = 1
}

variable "admin_size" {
  default = 1
}

variable "vpc_cidr" {
  default = "10.248.0.0/16"
}

variable "public_subnets" {
  type    = "list"
  default = ["10.248.11.0/24", "10.248.12.0/24", "10.248.13.0/24"]
}

variable "com_subnets" {
  type    = "list"
  default = ["10.248.21.0/24", "10.248.22.0/24", "10.248.23.0/24"]
}

variable "green_subnets" {
  type    = "list"
  default = ["10.248.31.0/24", "10.248.32.0/24", "10.248.33.0/24"]
}

variable "net_subnets" {
  type    = "list"
  default = ["10.248.41.0/24", "10.248.42.0/24", "10.248.43.0/24"]
}

variable "admin_subnets" {
  type    = "list"
  default = ["10.248.51.0/24", "10.248.52.0/24", "10.248.53.0/24"]
}

variable "db_subnets" {
  type    = "list"
  default = ["10.248.61.0/24", "10.248.62.0/24", "10.248.63.0/24"]
}

variable "kmaster_subnets" {
  type    = "list"
  default = ["10.248.91.0/24", "10.248.92.0/24", "10.248.93.0/24"]
}

variable "peering_subnets" {
  type    = "list"
  default = ["10.248.1.0/32", "10.248.1.10/32", "10.248.1.0/24"]
}

# Resources

//data "aws_availability_zones" "available" {}

resource "aws_key_pair" "cluster_key_pair" {
  key_name   = "${var.name}-key-pair"
  public_key = "${file(var.public_key_path)}"

  lifecycle {
    create_before_destroy = true
  }
}

module "vpc" {
  source = "../vpc"
  name   = "${var.name}-vpc"
  cidr   = "${var.vpc_cidr}"
  region = "${var.region}"
}

module "network" {
  source         = "../vpc/network"
  name           = "${var.name}"
  public_domain  = "${var.public_domain}"
  vpc_id         = "${module.vpc.id}"
  vpc_cidr       = "${module.vpc.cidr}"
  azs            = "${var.azs}"
  public_subnets = "${var.public_subnets}"
}

module "kmaster" {
  source                      = "../vpc/kmaster"
  name                        = "${var.name}-kmaster"
  vpc_id                      = "${module.vpc.id}"
  vpc_cidr                    = "${var.vpc_cidr}"
  azs                         = "${var.azs}"
  nat_ids                     = "${module.network.nat_gateway_ids}"
  subnets                     = "${var.kmaster_subnets}"
  key_name                    = "${aws_key_pair.cluster_key_pair.key_name}"
  alb_route53_zone_id_private = "${module.network.route53_private_id}"
  alb_route53_zone_id_public  = "${module.network.route53_public_id}"
  alb_subnet_ids              = "${module.network.public_subnet_ids}"
}

module "green_zone" {
  source   = "../vpc/knode"
  name     = "${var.name}-knodes-green"
  zone     = "green"
  size     = "${var.green_size}"
  vpc_id   = "${module.vpc.id}"
  vpc_cidr = "${var.vpc_cidr}"
  azs      = "${var.azs}"
  nat_ids  = "${module.network.nat_gateway_ids}"
  subnets  = "${var.green_subnets}"
  key_name = "${aws_key_pair.cluster_key_pair.key_name}"
}

module "net_zone" {
  source   = "../vpc/knode"
  name     = "${var.name}-knodes-net"
  zone     = "net"
  size     = "${var.net_size}"
  subnets  = "${var.net_subnets}"
  vpc_id   = "${module.vpc.id}"
  vpc_cidr = "${var.vpc_cidr}"
  azs      = "${var.azs}"
  nat_ids  = "${module.network.nat_gateway_ids}"
  key_name = "${aws_key_pair.cluster_key_pair.key_name}"
}

module "db_zone" {
  source   = "../vpc/knode"
  name     = "${var.name}-knodes-db"
  zone     = "db"
  size     = "${var.db_size}"
  subnets  = "${var.db_subnets}"
  vpc_id   = "${module.vpc.id}"
  vpc_cidr = "${var.vpc_cidr}"
  azs      = "${var.azs}"
  nat_ids  = "${module.network.nat_gateway_ids}"
  key_name = "${aws_key_pair.cluster_key_pair.key_name}"
}

module "admin_zone" {
  source   = "../vpc/knode"
  name     = "${var.name}-knodes-admin"
  zone     = "admin"
  size     = "${var.admin_size}"
  subnets  = "${var.admin_subnets}"
  vpc_id   = "${module.vpc.id}"
  vpc_cidr = "${var.vpc_cidr}"
  azs      = "${var.azs}"
  nat_ids  = "${module.network.nat_gateway_ids}"
  key_name = "${aws_key_pair.cluster_key_pair.key_name}"

  alb_enable                  = true
  alb_internal                = false
  alb_subnet_ids              = "${module.network.public_subnet_ids}"
  alb_dns_name_private        = "admin"
  alb_route53_zone_id_private = "${module.network.route53_private_id}"
  alb_dns_names_public        = ["*.admin.${var.public_domain}"]
  alb_route53_zone_id_public  = "${module.network.route53_public_id}"
}

module "com_zone" {
  source   = "../vpc/knode"
  name     = "${var.name}-knodes-com"
  zone     = "com"
  size     = "${var.com_size}"
  subnets  = "${var.com_subnets}"
  vpc_id   = "${module.vpc.id}"
  vpc_cidr = "${var.vpc_cidr}"
  azs      = "${var.azs}"
  nat_ids  = "${module.network.nat_gateway_ids}"
  key_name = "${aws_key_pair.cluster_key_pair.key_name}"

  alb_enable                  = true
  alb_internal                = false
  alb_subnet_ids              = "${module.network.public_subnet_ids}"
  alb_dns_name_private        = "com"
  alb_route53_zone_id_private = "${module.network.route53_private_id}"
}

resource "aws_network_acl" "acl" {
  vpc_id = "${module.vpc.id}"

  subnet_ids = [
    "${concat(
        module.network.public_subnet_ids,
        module.com_zone.subnet_ids,
        module.green_zone.subnet_ids,
        module.net_zone.subnet_ids,
        module.admin_zone.subnet_ids,
        module.db_zone.subnet_ids,
        module.kmaster.subnet_ids
    )}",
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

# OUTPUTS

output "name" {
  value = "${var.name}"
}

output "region" {
  value = "${var.region}"
}

//output "availability_zones" {
//  value = "${data.aws_availability_zones.available.names}"
//}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "vpc_cidr" {
  value = "${module.vpc.cidr}"
}
