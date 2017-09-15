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
  source = "../vpc/network"

  name            = "${var.name}"
  public_domain   = "${var.public_domain}"
  vpc_id          = "${module.vpc.id}"
  vpc_cidr        = "${module.vpc.cidr}"
  azs             = "${var.azs}"
  public_subnets  = "${var.public_subnets}"
  com_subnets     = "${var.com_subnets}"
  green_subnets   = "${var.green_subnets}"
  net_subnets     = "${var.net_subnets}"
  admin_subnets   = "${var.admin_subnets}"
  db_subnets      = "${var.db_subnets}"
  kmaster_subnets = "${var.kmaster_subnets}"
}

module "kmaster" {
  source                      = "../vpc/kmaster"
  name                        = "${var.name}-kmaster"
  vpc_id                      = "${module.vpc.id}"
  vpc_cidr                    = "${var.vpc_cidr}"
  azs                         = "${var.azs}"
  subnet_ids                  = "${module.network.kmaster_subnet_ids}"
  key_name                    = "${aws_key_pair.cluster_key_pair.key_name}"
  alb_route53_zone_id_private = "${module.network.route53_private_id}"
  alb_route53_zone_id_public  = "${module.network.route53_public_id}"
  alb_subnet_ids              = "${module.network.public_subnet_ids}"
}

module "green_zone" {
  source = "../vpc/knode"

  zone       = "green"
  size       = 1
  name       = "${var.name}-knodes-green"
  subnet_ids = "${module.network.green_subnet_ids}"
  vpc_id     = "${module.vpc.id}"
  vpc_cidr   = "${module.vpc.cidr}"
  azs        = "${var.azs}"
  key_name   = "${aws_key_pair.cluster_key_pair.key_name}"

  alb_enable = false
}

module "net_zone" {
  source = "../vpc/knode"

  zone       = "net"
  size       = 1
  name       = "${var.name}-knodes-net"
  subnet_ids = "${module.network.net_subnet_ids}"

  vpc_id   = "${module.vpc.id}"
  vpc_cidr = "${module.vpc.cidr}"
  azs      = "${var.azs}"
  key_name = "${aws_key_pair.cluster_key_pair.key_name}"

  alb_enable = false
}

module "db_zone" {
  source = "../vpc/knode"

  zone       = "db"
  size       = 1
  name       = "${var.name}-knodes-db"
  subnet_ids = "${module.network.db_subnet_ids}"

  vpc_id   = "${module.vpc.id}"
  vpc_cidr = "${module.vpc.cidr}"
  azs      = "${var.azs}"
  key_name = "${aws_key_pair.cluster_key_pair.key_name}"
}

module "admin_zone" {
  source = "../vpc/knode"

  zone       = "admin"
  size       = 1
  name       = "${var.name}-knodes-admin"
  subnet_ids = "${module.network.admin_subnet_ids}"

  vpc_id   = "${module.vpc.id}"
  vpc_cidr = "${module.vpc.cidr}"
  azs      = "${var.azs}"
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
  source = "../vpc/knode"

  zone       = "com"
  size       = 2
  name       = "${var.name}-knodes-com"
  subnet_ids = "${module.network.com_subnet_ids}"

  vpc_id   = "${module.vpc.id}"
  vpc_cidr = "${module.vpc.cidr}"
  azs      = "${var.azs}"
  key_name = "${aws_key_pair.cluster_key_pair.key_name}"

  alb_enable                  = true
  alb_internal                = false
  alb_subnet_ids              = "${module.network.public_subnet_ids}"
  alb_dns_name_private        = "com"
  alb_route53_zone_id_private = "${module.network.route53_private_id}"
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
