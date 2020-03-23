variable "name" {
}

variable "vpc_id" {
}

variable "listeners_count" {
  default = 0
}

variable "listeners" {
  //  type = list(object({
  //    port            = number
  //    protocol        = string
  //    health_check    = string
  //    certificate_arn = string
  //  }))
  default = []
}

variable "subnet_ids" {
  type = list(string)
}

variable "internal" {
  default = false
}

variable "enable" {
  default = true
}

variable "route53_zone_id_private" {
}

variable "dns_name_private" {
}

variable "route53_zone_id_public" {
  default = ""
}

variable "dns_names_public" {
  type    = list(string)
  default = []
}
