provider "aws" {
  region                  = var.region
  shared_credentials_file = "../step-0/aws_credentials"
}

# DNS
resource "aws_route53_zone" "public" {
  name = var.public_domain
}

# Certs

module "com_cert" {
  source      = "../../vpc/certificate"
  domain_name = var.public_domain
  subject_alternative_names = [
    "*.${var.public_domain}",
  ]
  zone_id = aws_route53_zone.public.zone_id
}

# AMI

module "packer" {
  source   = "../../packer"
  name     = "${var.name}-packer"
  ami_name = var.ami_name
  region   = var.region
  az       = var.azs[0]

  AWS_SHARED_CREDENTIALS_FILE = "${path.module}/../step-0/aws_credentials"
}

