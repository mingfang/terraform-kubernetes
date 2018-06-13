variable name {}

variable public_domain {}

variable "region" {}

variable "azs" {
  type    = "list"
}

variable "public_key_path" {}

variable "access_key" {}

variable "secret_key" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Required before creating cluster

resource "aws_route53_zone" "public" {
  name = "${var.public_domain}"
}

module "com_cert" {
  source      = "../vpc/certifcate"
  domain_name = "*.${var.public_domain}"
  zone_id     = "${aws_route53_zone.public.zone_id}"
}

module "admin_cert" {
  source      = "../vpc/certifcate"
  domain_name = "*.admin.${var.public_domain}"
  zone_id     = "${aws_route53_zone.public.zone_id}"
}

# Storage

module "backup" {
  source            = "../vpc/ebs_backup"
  name              = "${var.name}"
  default_retention = "7"
}

resource "aws_ebs_volume" "db_us-west-2a" {
  availability_zone = "us-west-2a"
  size              = 10

  tags {
    Name   = "${var.name}-db-2a"
    Backup = "${var.name}"
    Zone   = "db"
  }
}

resource "aws_ebs_volume" "db_us-west-2b" {
  availability_zone = "us-west-2b"
  size              = 10

  tags {
    Name   = "${var.name}-db-2b"
    Backup = "${var.name}"
    Zone   = "db"
  }
}

# Cluster

module "cluster" {
  source = "../kubernetes"
  name   = "${var.name}"

  region          = "${var.region}"
  azs             = "${var.azs}"
  access_key      = "${var.access_key}"
  secret_key      = "${var.secret_key}"
  public_key_path = "${var.public_key_path}"
  route53_zone_id = "${aws_route53_zone.public.zone_id}"

  kmaster_instance_type = "t2.micro"

  com_size            = 2
  com_instance_type   = "t2.micro"
  com_certificate_arn = "${module.com_cert.arn}"

  admin_size            = 1
  admin_instance_type   = "t2.micro"
  admin_certificate_arn = "${module.admin_cert.arn}"

  green_size          = 0
  green_instance_type = "t2.micro"

  net_size          = 0
  net_instance_type = "t2.micro"

  db_size          = 2
  db_instance_type = "t2.micro"
}
