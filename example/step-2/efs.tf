variable "efs_provisioned_throughput_in_mibps" {
  default = null
}

variable efs_transition_to_ia {
  type    = string
  default = "AFTER_7_DAYS"
}

// EFS for KMaster state
module "efs" {
  source = "../../vpc/efs"
  name   = "${var.cluster_name}-efs"

  vpc_id                          = local.vpc_id
  region                          = var.region
  subnet_ids                      = local.private_subnet_ids
  dns_name                        = "cluster-data"
  route53_zone_id                 = local.private_route53_zone_id
  transition_to_ia                = var.efs_transition_to_ia
  provisioned_throughput_in_mibps = var.efs_provisioned_throughput_in_mibps
}
