variable "name" {
}

variable "route53_zone_id" {
}

data "aws_route53_zone" "public" {
  zone_id = var.route53_zone_id
}

variable "access_key" {
}

variable "secret_key" {
}

variable "public_key_path" {
}

variable "region" {
}

variable "azs" {
  type = list(string)
}

variable "vpc_cidr" {
  default = "10.248.0.0/16"
}

variable "com_size" {
  default = 0
}

variable "com_instance_type" {
  default = "t3a.medium"
}

variable "com_volume_size" {
  default = "24"
}

variable "green_size" {
  default = 0
}

variable "green_instance_type" {
  default = "t3a.medium"
}

variable "green_subnets" {
  type    = list(string)
  default = ["10.248.31.0/24", "10.248.32.0/24", "10.248.33.0/24"]
}

variable "green_volume_size" {
  default = "24"
}

variable "net_size" {
  default = 0
}

variable "net_instance_type" {
  default = "t3a.medium"
}

variable "net_subnets" {
  type    = list(string)
  default = ["10.248.41.0/24", "10.248.42.0/24", "10.248.43.0/24"]
}

variable "net_volume_size" {
  default = "24"
}

variable "db_size" {
  default = 0
}

variable "db_instance_type" {
  default = "t3a.medium"
}

variable "db_subnets" {
  type    = list(string)
  default = ["10.248.61.0/24", "10.248.62.0/24", "10.248.63.0/24"]
}

variable "db_volume_size" {
  default = "24"
}

variable "spot_size" {
  default = 0
}

variable "spot_instance_type" {
  default = "t3a.medium"
}

variable "spot_subnets" {
  type    = list(string)
  default = ["10.248.81.0/24", "10.248.82.0/24", "10.248.83.0/24"]
}

variable "spot_volume_size" {
  default = "24"
}

variable "admin_size" {
  default = 0
}

variable "admin_instance_type" {
  default = "t3a.medium"
}

variable "admin_subnets" {
  type    = list(string)
  default = ["10.248.51.0/24", "10.248.52.0/24", "10.248.53.0/24"]
}

variable "admin_volume_size" {
  default = "24"
}

variable "kmaster_instance_type" {
  default = "t3a.medium"
}

variable "bastion_instance_type" {
  default = "t3a.nano"
}

variable "bastion_enable" {}

variable "public_subnets" {
  type    = list(string)
  default = ["10.248.11.0/24", "10.248.12.0/24", "10.248.13.0/24"]
}

variable "com_subnets" {
  type    = list(string)
  default = ["10.248.21.0/24", "10.248.22.0/24", "10.248.23.0/24"]
}

variable "efs_subnets" {
  type    = list(string)
  default = ["10.248.71.0/24", "10.248.72.0/24", "10.248.73.0/24"]
}

variable "kmaster_subnets" {
  type    = list(string)
  default = ["10.248.91.0/24", "10.248.92.0/24", "10.248.93.0/24"]
}

variable "peering_subnets" {
  type    = list(string)
  default = ["10.248.1.0/32", "10.248.1.10/32", "10.248.1.0/24"]
}

variable "admin_certificate_arn" {
  default = ""
}

variable "com_certificate_arn" {
  default = ""
}

variable "ami_id" {
}
