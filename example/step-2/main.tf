provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# Cluster

data "aws_route53_zone" "public" {
  name = var.public_domain
}

data "aws_acm_certificate" "com_cert" {
  domain   = "*.${var.public_domain}"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "admin_cert" {
  domain   = "*.admin.${var.public_domain}"
  statuses = ["ISSUED"]
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.ami_name]
  }
}

module "kubernetes" {
  source          = "../../kubernetes"
  name            = var.name
  region          = var.region
  azs             = var.azs
  access_key      = var.access_key
  secret_key      = var.secret_key
  public_key_path = var.public_key_path
  route53_zone_id = data.aws_route53_zone.public.id
  ami_id          = data.aws_ami.ami.id
  bastion_enable = true

  kmaster_instance_type = "t3a.medium"

  com_size            = 0
  com_instance_type   = "t3a.micro"
  com_certificate_arn = data.aws_acm_certificate.com_cert.arn

  admin_size            = 0
  admin_instance_type   = "t3a.micro"
  admin_certificate_arn = data.aws_acm_certificate.admin_cert.arn

  green_size          = 1
  green_instance_type = "t3a.micro"

  net_size          = 0
  net_instance_type = "t3a.micro"

  db_size          = 0
  db_instance_type = "t3a.medium"
}

# Storage
/*
resource "aws_ebs_volume" "volume1" {
  availability_zone = "us-west-2a"
  size              = 10
  encrypted         = true

  tags {
    Name   = "volume1"
    Backup = "default"

    //    Zone   = "db"
  }
}

resource "aws_ebs_volume" "volume2" {
  availability_zone = "us-west-2a"
  size              = 10
  encrypted         = true

  tags {
    Name   = "volume2"
    Backup = "default"

    //    Zone   = "db"
  }
}
*/
