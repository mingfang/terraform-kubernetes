
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

variable "zone" {
}

variable "size" {
}


variable "on_demand_base_capacity" {
  type        = number
  default     = null
  description = "Setting on_demand_base_capacity < size would result in (size - on_demand_base_capacity) spot instances; null == no spot"
}

variable "alb_enable" {
  default = false
}

variable "alb_internal" {
  default = true
}

variable "alb_dns_name_private" {
  default = ""
}

variable "alb_dns_names_public" {
  type    = list(string)
  default = []
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

variable "security_group_id" {
}

variable "image_id" {
}

variable "kmaster" {
}

variable "certificate_arn" {
  default = ""
}

variable "volume_size" {
}

variable "taints" {
  default = ""
}

// transit gateway
variable "transit_gateway_id" {
  default = null
}
variable "transit_gateway_destination_cidr_blocks" {
  type    = list(string)
  default = []
}
