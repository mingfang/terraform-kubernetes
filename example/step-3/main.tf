provider "aws" {
  region                  = var.region
  shared_credentials_file = "../step-0/aws_credentials"
}

module "aws" {
  source       = "./aws"
  cluster_name = var.cluster_name
}

module "ingress" {
  source = "./ingress"
}

data "aws_efs_file_system" "efs" {
  creation_token = "${var.cluster_name}-efs"
}

module "efs" {
  source = "./efs"

  aws_region     = var.region
  file_system_id = data.aws_efs_file_system.efs.file_system_id
  dns_name       = "cluster-data.${var.cluster_name}.private"
}
