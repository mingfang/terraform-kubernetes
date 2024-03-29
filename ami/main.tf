provider "aws" {
  region                  = var.region
  shared_credentials_file = "./aws_credentials"
}

module "vpc" {
  source = "../packer/vpc"
  name   = "packer"
  region = var.region
  az     = var.azs[0]
}

module "kubernetes-1-21-0-2" {
  source    = "../packer"
  region    = module.vpc.region
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  ami_name                    = "kubernetes-1.21.0-2"
  AWS_SHARED_CREDENTIALS_FILE = "${path.module}/aws_credentials"
}
module "kubernetes-1-21-0-3" {
  source    = "../packer"
  region    = module.vpc.region
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  ami_name                    = "kubernetes-1.21.0-3"
  AWS_SHARED_CREDENTIALS_FILE = "${path.module}/aws_credentials"
}

module "kubernetes-1-21-0-5" {
  source    = "../packer"
  region    = module.vpc.region
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  ami_name                    = "kubernetes-1.21.0-5"
  AWS_SHARED_CREDENTIALS_FILE = "${path.module}/aws_credentials"
}

module "kubernetes-1-21-0-6" {
  source    = "../packer"
  region    = module.vpc.region
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  ami_name                    = "kubernetes-1.21.0-6"
  AWS_SHARED_CREDENTIALS_FILE = "${path.module}/aws_credentials"
}

module "kubernetes-1-21-0-8" {
  source    = "../packer"
  region    = module.vpc.region
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id

  ami_name                    = "kubernetes-1.21.0-8"
  AWS_SHARED_CREDENTIALS_FILE = "${path.module}/aws_credentials"
}
