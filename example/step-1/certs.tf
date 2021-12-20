# Certs

module "com_cert" {
  source      = "../../vpc/certificate"
  domain_name = var.public_domain
  subject_alternative_names = [
    "*.${var.public_domain}",
  ]
  zone_id = aws_route53_zone.public.zone_id
}
