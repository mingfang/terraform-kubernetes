variable "name" {
}

variable "vpc_id" {
}

variable "vpc_cidr" {
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "transit_gateway_destination_cidr_blocks" {
  type    = list(string)
  default = []
}
