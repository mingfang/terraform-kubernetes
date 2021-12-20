variable "name" {}

variable "cluster_name" {}

variable "vpc_id" {}

variable "key_name" {}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_type" {}

variable "image_id" {}

variable "efs_dns_name" {}

variable "security_group_ids" {
  default     = []
  description = "add EFS security group"
}

// Load Balancers
variable "lb_public_fqdn" {
  description = "public Route53 name"
}
variable "lb_private_fqdn" {
  description = "private Route53 name"
}
variable "target_group_arns" {
  description = "LB target_group_arns"
}

// start.sh
variable "environments" {
  default     = []
  description = "Docker daemon conf"
}
variable "insecure_registry" {
  default     = null
  description = "Docker daemon conf"
}

variable "use_spot" {
  default = false
}