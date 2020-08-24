variable "name" {
}

variable "enable" {
  default = true
}

variable "vpc_id" {
}

variable "key_name" {
}

variable "subnet_id" {
}

variable "instance_type" {
  default = "t2.micro"
}

variable "image_id" {
}

variable "route53_zone_id" {
}

variable "associate_public_ip_address" {
  default = true

}