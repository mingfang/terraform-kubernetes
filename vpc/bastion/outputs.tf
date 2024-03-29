output "fqdn" {
  value = var.enable && length(aws_route53_record.bastion) > 0 ? aws_route53_record.bastion.0.fqdn : ""
}

output "private_ip" {
  value = var.enable ? aws_instance.bastion.0.private_ip : ""
}