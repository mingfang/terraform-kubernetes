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
