variable "name" {}

variable "region" {}

variable "vpc_id" {}

variable "subnet_ids" {}

variable "dns_name" {}

variable "route53_zone_id" {}

variable "performance_mode" {
  default = "generalPurpose"
}

variable "provisioned_throughput_in_mibps" {
  type    = number
  default = null
}

variable transition_to_ia {
  type    = string
  default = "AFTER_7_DAYS"
}

variable transition_to_primary_storage_class {
  type    = string
  default = "AFTER_1_ACCESS"
}

variable tags {
  type = map
  default = {}
}
