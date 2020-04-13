variable "name" {
}

variable "region" {
}

variable "vpc_id" {
}

variable "security_group_ids" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "dns_name" {
}

variable "route53_zone_id" {
}

variable "performance_mode" {
  default = "generalPurpose"
}

variable "provisioned_throughput_in_mibps" {
  type    = number
  default = null
}

variable transition_to_ia {
  type    = string
  default = null
}
