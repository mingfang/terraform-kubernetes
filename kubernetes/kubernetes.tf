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
  default = 1
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

variable com_instance_type {
  default = "t2.medium"
}

variable green_instance_type {
  default = "t2.medium"
}

variable net_instance_type {
  default = "t2.medium"
}

variable db_instance_type {
  default = "t2.medium"
}

variable admin_instance_type {
  default = "t2.medium"
}

variable kmaster_instance_type {
  default = "t2.medium"
}

variable bastion_instance_type {
  default = "t2.micro"
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

variable "efs_subnets" {
  type    = "list"
  default = ["10.248.71.0/24", "10.248.72.0/24", "10.248.73.0/24"]
}

variable "kmaster_subnets" {
  type    = "list"
  default = ["10.248.91.0/24", "10.248.92.0/24", "10.248.93.0/24"]
}

variable "peering_subnets" {
  type    = "list"
  default = ["10.248.1.0/32", "10.248.1.10/32", "10.248.1.0/24"]
}

variable "admin_certificate_arn" {
  default = ""
}

variable "com_certificate_arn" {
  default = ""
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

data "aws_ami" "kubernetes" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["kubernetes"]
  }
}

module "bastion" {
  source          = "../vpc/bastion"
  name            = "${var.name}-bastion"
  instance_type   = "${var.bastion_instance_type}"
  image_id        = "${data.aws_ami.kubernetes.id}"
  key_name        = "${aws_key_pair.cluster_key_pair.key_name}"
  vpc_id          = "${module.vpc.id}"
  vpc_cidr        = "${var.vpc_cidr}"
  subnet_id       = "${element(module.network.public_subnet_ids, 0)}"
  route53_zone_id = "${module.network.route53_public_id}"
}

module "kmaster" {
  source                      = "./kmaster"
  name                        = "${var.name}-kmaster"
  instance_type               = "${var.kmaster_instance_type}"
  vpc_id                      = "${module.vpc.id}"
  vpc_cidr                    = "${var.vpc_cidr}"
  azs                         = "${var.azs}"
  nat_ids                     = "${module.network.nat_gateway_ids}"
  subnets                     = "${var.kmaster_subnets}"
  key_name                    = "${aws_key_pair.cluster_key_pair.key_name}"
  alb_route53_zone_id_private = "${module.network.route53_private_id}"
  alb_route53_zone_id_public  = "${module.network.route53_public_id}"
  alb_subnet_ids              = "${module.network.public_subnet_ids}"
  image_id                    = "${data.aws_ami.kubernetes.id}"
  efs_dns_name                = "${module.efs.fqdn}"
}

module "green_zone" {
  source            = "./knode"
  name              = "${var.name}-knodes-green"
  zone              = "green"
  size              = "${var.green_size}"
  instance_type     = "${var.green_instance_type}"
  vpc_id            = "${module.vpc.id}"
  vpc_cidr          = "${var.vpc_cidr}"
  azs               = "${var.azs}"
  nat_ids           = "${module.network.nat_gateway_ids}"
  subnets           = "${var.green_subnets}"
  key_name          = "${aws_key_pair.cluster_key_pair.key_name}"
  security_group_id = "${module.network.security_group_id}"
  image_id          = "${data.aws_ami.kubernetes.id}"
  kmaster           = "${module.kmaster.private_fqdn}"
}

module "net_zone" {
  source            = "./knode"
  name              = "${var.name}-knodes-net"
  zone              = "net"
  size              = "${var.net_size}"
  instance_type     = "${var.net_instance_type}"
  subnets           = "${var.net_subnets}"
  vpc_id            = "${module.vpc.id}"
  vpc_cidr          = "${var.vpc_cidr}"
  azs               = "${var.azs}"
  nat_ids           = "${module.network.nat_gateway_ids}"
  key_name          = "${aws_key_pair.cluster_key_pair.key_name}"
  security_group_id = "${module.network.security_group_id}"
  image_id          = "${data.aws_ami.kubernetes.id}"
  kmaster           = "${module.kmaster.private_fqdn}"
}

module "db_zone" {
  source            = "./knode"
  name              = "${var.name}-knodes-db"
  zone              = "db"
  size              = "${var.db_size}"
  instance_type     = "${var.db_instance_type}"
  subnets           = "${var.db_subnets}"
  vpc_id            = "${module.vpc.id}"
  vpc_cidr          = "${var.vpc_cidr}"
  azs               = "${var.azs}"
  nat_ids           = "${module.network.nat_gateway_ids}"
  key_name          = "${aws_key_pair.cluster_key_pair.key_name}"
  security_group_id = "${module.network.security_group_id}"
  image_id          = "${data.aws_ami.kubernetes.id}"
  kmaster           = "${module.kmaster.private_fqdn}"
}

module "admin_zone" {
  source            = "./knode"
  name              = "${var.name}-knodes-admin"
  zone              = "admin"
  size              = "${var.admin_size}"
  instance_type     = "${var.admin_instance_type}"
  subnets           = "${var.admin_subnets}"
  vpc_id            = "${module.vpc.id}"
  vpc_cidr          = "${var.vpc_cidr}"
  azs               = "${var.azs}"
  nat_ids           = "${module.network.nat_gateway_ids}"
  key_name          = "${aws_key_pair.cluster_key_pair.key_name}"
  security_group_id = "${module.network.security_group_id}"
  image_id          = "${data.aws_ami.kubernetes.id}"
  kmaster           = "${module.kmaster.private_fqdn}"
  certificate_arn   = "${var.admin_certificate_arn}"

  alb_enable                  = "${var.admin_size > 0}"
  alb_internal                = false
  alb_subnet_ids              = "${module.network.public_subnet_ids}"
  alb_dns_name_private        = "admin"
  alb_route53_zone_id_private = "${module.network.route53_private_id}"
  alb_dns_names_public        = ["*.admin.${var.public_domain}"]
  alb_route53_zone_id_public  = "${module.network.route53_public_id}"
}

module "com_zone" {
  source            = "./knode"
  name              = "${var.name}-knodes-com"
  zone              = "com"
  size              = "${var.com_size}"
  instance_type     = "${var.com_instance_type}"
  subnets           = "${var.com_subnets}"
  vpc_id            = "${module.vpc.id}"
  vpc_cidr          = "${var.vpc_cidr}"
  azs               = "${var.azs}"
  nat_ids           = "${module.network.nat_gateway_ids}"
  key_name          = "${aws_key_pair.cluster_key_pair.key_name}"
  security_group_id = "${module.network.security_group_id}"
  image_id          = "${data.aws_ami.kubernetes.id}"
  kmaster           = "${module.kmaster.private_fqdn}"
  certificate_arn   = "${var.com_certificate_arn}"

  alb_enable                  = "${var.com_size > 0}"
  alb_internal                = false
  alb_subnet_ids              = "${module.network.public_subnet_ids}"
  alb_dns_name_private        = "com"
  alb_route53_zone_id_private = "${module.network.route53_private_id}"
  alb_dns_names_public        = ["*.${var.public_domain}"]
  alb_route53_zone_id_public  = "${module.network.route53_public_id}"
}

module "efs" {
  source             = "../vpc/efs"
  name               = "${var.name}-efs"
  vpc_id             = "${module.vpc.id}"
  region             = "${var.region}"
  azs                = "${var.azs}"
  subnets            = "${var.efs_subnets}"
  security_group_ids = ["${module.network.security_group_id}", "${module.kmaster.security_group_id}"]
  dns_name           = "cluster-data"
  route53_zone_id    = "${module.network.route53_private_id}"
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

output "efs_fqdn" {
  value = "${module.efs.efs_id}.efs.${var.region}.amazonaws.com"
}

output "bastion_fqdn" {
  value = "${module.bastion.fqdn}"
}

output "kmaster_fqdn" {
  value = "${module.kmaster.public_fqdn}"
}

output "route53_private_id" {
  value = "${module.network.route53_private_id}"
}

output "route53_public_id" {
  value = "${module.network.route53_public_id}"
}
