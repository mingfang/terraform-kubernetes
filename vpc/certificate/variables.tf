variable "domain_name" {}

variable "subject_alternative_names" {
  default = []
  type    = list(string)
}

variable "zone_id" {}

variable "enable" {
  default = true
}
