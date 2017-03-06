variable "access_key" {}

variable "secret_key" {}

variable "public_key_path" {}

variable "region" {}

variable "azs" {
  type = "list"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "cluster1" {
  source = "./cluster"

  name            = "cluster1"
  region          = "${var.region}"
  azs             = "${var.azs}"
  access_key      = "${var.access_key}"
  secret_key      = "${var.secret_key}"
  public_key_path = "${var.public_key_path}"
}

//module "cluster2" {
//  source = "./cluster"
//
//  name            = "cluster2"
//  region          = "${var.region}"
//  azs             = "${var.azs}"
//  access_key      = "${var.access_key}"
//  secret_key      = "${var.secret_key}"
//  public_key_path = "${var.public_key_path}"
//}

output "region" {
  value = "${var.region}"
}
