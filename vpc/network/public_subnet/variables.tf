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

variable "internet_gateway_id" {
  default = ""
}
