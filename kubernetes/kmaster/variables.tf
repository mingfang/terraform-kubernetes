variable "name" {
}

variable "vpc_id" {
}

variable "vpc_cidr" {
}

variable "key_name" {
}

variable "azs" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "nat_ids" {
  type = list(string)
}

variable "instance_type" {
}

variable "image_id" {
}

variable "efs_dns_name" {
  default = ""
}

variable "alb_route53_zone_id_private" {
  default = ""
}

variable "alb_route53_zone_id_public" {
  default = ""
}

variable "alb_subnet_ids" {
  type    = list(string)
  default = []
}
