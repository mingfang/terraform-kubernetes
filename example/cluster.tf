variable "access_key" {}

variable "secret_key" {}

variable name {
  default = "example"
}

variable "region" {
  default = "us-west-2"
}

variable "azs" {
  type    = "list"
  default = ["us-west-2a", "us-west-2b"]
}

variable public_domain {
  default = "example.rebelsoft.com"
}

variable "public_key_path" {
  default = "key.pub"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "cluster" {
  source                = "../kubernetes"
  name                  = "${var.name}"
  public_domain         = "${var.public_domain}"
  region                = "${var.region}"
  azs                   = "${var.azs}"
  access_key            = "${var.access_key}"
  secret_key            = "${var.secret_key}"
  public_key_path       = "${var.public_key_path}"
  kmaster_instance_type = "t2.medium"
  com_size              = 1
  com_instance_type     = "t2.medium"
  green_size            = 1
  green_instance_type   = "t2.medium"
  net_size              = 0
  db_size               = 0
  admin_size            = 2
  admin_instance_type   = "t2.medium"
}

output "bastion_fqdn" {
  value = "${module.cluster.bastion_fqdn}"
}
