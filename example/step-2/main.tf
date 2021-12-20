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
  key_name   = "${var.name}-key-pair"
  public_key = file("${path.module}/key.pub")

  lifecycle {
    create_before_destroy = false
  }
}

// EFS for KMaster state
module "efs" {
  source = "../../vpc/efs"
  name   = "${var.name}-efs"

  vpc_id                          = local.vpc_id
  region                          = var.region
  subnet_ids                      = local.private_subnet_ids
  dns_name                        = "cluster-data"
  route53_zone_id                 = module.network.route53_private.id
  transition_to_ia                = var.efs_transition_to_ia
  provisioned_throughput_in_mibps = var.efs_provisioned_throughput_in_mibps
}
