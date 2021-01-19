variable "name" {
  description = "the name of this cluster"
}

variable "public_domain" {
  description = "you public domain, e.g. example.com"
}

variable "region" {
  default = "us-east-1"
  description = "choose your region"
}

variable "azs" {
  default = ["us-east-1b", "us-east-1f"]
  description = "choose your availability zones. Must have at least two."
}

variable "ami_name" {
  default = "kubernetes-1.18.1"
  description = "name of AMI to be created by Packer"
}
