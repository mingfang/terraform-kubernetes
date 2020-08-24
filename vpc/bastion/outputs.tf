output "fqdn" {
  value = var.enable && length(aws_route53_record.bastion) > 0 ? aws_route53_record.bastion.0.fqdn : ""
}