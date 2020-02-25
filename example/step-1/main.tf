provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

/* Required before creating cluster */

# DNS
resource "aws_route53_zone" "public" {
  name = var.public_domain
}

# Certs

module "com_cert" {
  source                    = "../../vpc/certificate"
  domain_name               = "*.${var.public_domain}"
  subject_alternative_names = [var.public_domain]
  zone_id                   = aws_route53_zone.public.zone_id
}

module "admin_cert" {
  source      = "../../vpc/certificate"
  domain_name = "*.admin.${var.public_domain}"
  zone_id     = aws_route53_zone.public.zone_id
}

# Backup

module "backup" {
  source            = "../../vpc/ebs_backup"
  name              = "default"
  default_retention = "7"
}

# AMI

module "packer" {
  source     = "../../packer"
  name       = "${var.name}-packer"
  ami_name   = var.ami_name
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  az         = var.azs[0]
}

