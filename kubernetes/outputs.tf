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

