variable "com_size" {}
variable "com_instance_type" {}
variable "com_volume_size" {}

data "aws_acm_certificate" "com_cert" {
  domain   = var.public_domain
  statuses = ["ISSUED"]
}

module "com_lb" {
  source     = "../../vpc/lb"
  name       = "${var.cluster_name}-com"
  vpc_id     = local.vpc_id
  subnet_ids = local.public_subnet_ids
  internal   = false

  load_balancer_type = "application"
  idle_timeout       = 300
  route53_zone_id    = data.aws_route53_zone.public.id
  dns_names = [
    data.aws_route53_zone.public.name,
    "*.${data.aws_route53_zone.public.name}",
  ]

  listeners = [
    {
      port         = 80
      protocol     = "HTTP"
      health_check = "/healthz"
    },
    {
      port            = 443
      protocol        = "HTTPS"
      health_check    = "/healthz"
      certificate_arn = data.aws_acm_certificate.com_cert.arn
    },
  ]
}

module "com_zone" {
  source       = "../../kubernetes/knode"
  cluster_name = var.cluster_name
  zone         = "com"

  size                    = var.com_size
  max_size                = 10
  on_demand_base_capacity = 0 #all spot
  volume_size             = var.com_volume_size
  instance_type           = var.com_instance_type
  image_id                = data.aws_ami.kubernetes.image_id

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids
  key_name   = aws_key_pair.cluster_key_pair.key_name
  security_group_ids = [
    module.network.security_group_id,
  ]
  nat_ids           = []
  kmaster           = module.kmaster_lb_private.fqdn
  target_group_arns = module.com_lb.target_group_arns
}
