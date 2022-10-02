variable "cluster_name" {}

variable "vpc_id" {}

variable "key_name" {}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_type" {}

variable "image_id" {}

variable "kmaster" {}

variable "volume_size" {}

variable "zone" {}

variable "size" {
  default = 0
}

variable "min_size" {
  default = null
}

variable "max_size" {
  default = null
}

variable "on_demand_base_capacity" {
  type        = number
  default     = null
  description = "Setting on_demand_base_capacity < size would result in (size - on_demand_base_capacity) spot instances; null == no spot"
}

variable "target_group_arns" {
  default     = []
  description = "ALB target_group_arns"
}

variable "taints" {
  default = ""
}

variable "nat_ids" {
  type = list(string)
}

// transit gateway
variable "transit_gateway_id" {
  default = null
}
variable "transit_gateway_destination_cidr_blocks" {
  default = []
}

variable "security_group_ids" {
  default     = []
  description = "add EFS security group"
}

// start.sh
variable "environments" {
  default = []
}
variable "insecure_registry" {
  default = null
}

variable "docker_config_json" {
  default     = ""
  description = "registry auth"
}
