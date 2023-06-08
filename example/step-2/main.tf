provider "aws" {
  region                  = var.region
  shared_credentials_file = "../step-0/aws_credentials"
}

data "aws_route53_zone" "public" {
  name = var.public_domain
}

data "aws_ami" "kubernetes" {
  most_recent = true
  owners      = ["177368686266"]

  filter {
    name   = "name"
    values = [var.ami_name]
  }
}

// SSH keys for all EC2 instances and bastion
resource "aws_key_pair" "cluster_key_pair" {
  key_name   = "${var.cluster_name}-key-pair"
  public_key = file("${path.module}/key.pub")

  lifecycle {
    create_before_destroy = false
  }
}

