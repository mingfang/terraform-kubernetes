variable "access_key" {}

variable "secret_key" {}

variable "public_key_path" {}

variable name {}

variable "region" {}

variable "azs" {
  type = "list"
}

variable public_domain {
  default = ""
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "cluster" {
  source              = "./kubernetes"
  name                = "${var.name}"
  public_domain       = "${var.public_domain}"
  region              = "${var.region}"
  azs                 = "${var.azs}"
  access_key          = "${var.access_key}"
  secret_key          = "${var.secret_key}"
  public_key_path     = "${var.public_key_path}"
  com_size            = 0
  green_size          = 0
  green_instance_type = "t2.medium"
  net_size            = 0
  db_size             = 0
  admin_size          = 0
  admin_instance_type = "t2.medium"
}

output "bastion_fqdn" {
  value = "${module.cluster.bastion_fqdn}"
}
