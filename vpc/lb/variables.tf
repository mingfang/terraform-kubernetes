variable "name" {
}

variable "vpc_id" {
}

variable "load_balancer_type" {
  default = "application"
}

variable "listeners" {
  default = []
}

variable "subnet_ids" {
  type = list(string)
}

variable "internal" {
  default = false
}

variable "route53_zone_id" {
}

variable "dns_names" {
  type    = list(string)
  default = []
}
