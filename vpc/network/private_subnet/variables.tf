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

variable "enable" {
  default = true
}
