variable "kmaster_instance_type" {
  default = "t3a.medium"
}

module "kmaster_lb_public" {
  source = "../../vpc/lb"
  name   = "${var.cluster_name}-kmaster-public"

  load_balancer_type = "network"
  internal           = false
  vpc_id             = local.vpc_id
  subnet_ids         = local.public_subnet_ids

  route53_zone_id = data.aws_route53_zone.public.id
  dns_names       = ["kmaster"]

  listeners = [
    {
      port     = 6443
      protocol = "TCP"
    },
  ]
}

module "kmaster_lb_private" {
  source = "../../vpc/lb"
  name   = "${var.cluster_name}-kmaster-private"

  load_balancer_type = "network"
  internal           = true
  vpc_id             = local.vpc_id
  subnet_ids         = local.private_subnet_ids

  route53_zone_id = local.private_route53_zone_id
  dns_names       = ["kmaster"]

  listeners = [
    {
      port     = 6443
      protocol = "TCP"
    },
    {
      port     = 8200
      protocol = "TCP"
    },
  ]
}

module "kmaster" {
  source       = "../../kubernetes/kmaster"
  cluster_name = "${var.cluster_name}-kmaster"

  use_spot      = true
  instance_type = var.kmaster_instance_type
  image_id      = data.aws_ami.kubernetes.image_id

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids
  key_name   = aws_key_pair.cluster_key_pair.key_name

  security_group_ids = concat(
    local.security_group_ids,
    [module.efs.mount_target_client_security_group_id],
  )

  lb_private_fqdn   = module.kmaster_lb_private.fqdn
  lb_public_fqdn    = module.kmaster_lb_public.fqdn
  target_group_arns = concat(
    module.kmaster_lb_private.target_group_arns,
    module.kmaster_lb_public.target_group_arns,
  )
  efs_dns_name      = module.efs.private_fqdn

  insecure_registry = null
  environments      = []

  docker_config_json = var.docker_config_json
}
