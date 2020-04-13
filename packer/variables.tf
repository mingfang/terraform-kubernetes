variable "ami_name" {}

variable "region" {}

variable "az" {}

variable "name" {}

variable "vpc_cidr" {
  default = "10.0.0.0/24"
}

variable "subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "AWS_SHARED_CREDENTIALS_FILE" {}

