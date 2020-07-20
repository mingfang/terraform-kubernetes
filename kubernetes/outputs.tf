output "vpc" {
  value = module.vpc.this
}

output "efs_fqdn" {
  value = "${module.efs.efs_id}.efs.${var.region}.amazonaws.com"
}

output "bastion_fqdn" {
  value = module.bastion.fqdn
}

output "kmaster_fqdn" {
  value = module.kmaster.public_fqdn
}

output "route53_private" {
  value = module.network.route53_private
}

output "green_zone" {
  value = module.green_zone
}
output "net_zone" {
  value = module.net_zone
}
output "spot_zone" {
  value = module.spot_zone
}

