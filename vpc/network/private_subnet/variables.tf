variable "name" {
}

variable "vpc_id" {
}

variable "cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "nat_gateway_ids" {
  type = list(string)
}

variable "nat_support" {
  default = true
}

variable "transit_gateway_id" {
  default = null
}
variable "transit_gateway_destination_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "enable" {
  default = true
}
