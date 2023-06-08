variable "green_size" {
  default = 1
}

variable "green_instance_type" {
  default = "m5a.xlarge"
}

variable "green_volume_size" {
  default = "64"
}

module "green_zone" {
  source       = "../../kubernetes/knode"
  cluster_name = var.cluster_name
  zone         = "green"

  size                    = var.green_size
  max_size                = 10
  on_demand_base_capacity = 0 #all spot
  volume_size             = var.green_volume_size
  instance_type           = var.green_instance_type
  image_id                = data.aws_ami.kubernetes.image_id

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids
  key_name   = aws_key_pair.cluster_key_pair.key_name
  security_group_ids = concat(
    local.security_group_ids,
    [module.efs.mount_target_client_security_group_id],
  )
  nat_ids = []
  kmaster = module.kmaster_lb_private.fqdn

  insecure_registry = null
  environments      = []
}
