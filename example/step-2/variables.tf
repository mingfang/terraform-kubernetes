variable "name" {
  description = "the name of this cluster"
}

variable "cidr" {}
variable "public_subnets" {}
variable "private_subnets" {}

variable "public_domain" {
  description = "you public domain, e.g. example.com"
}

variable "ami_name" {}
variable "public_key_path" {}


variable "transit_gateway_destination_cidr_blocks" {}
variable "efs_provisioned_throughput_in_mibps" {}
variable "efs_transition_to_ia" {
  type = string
}


