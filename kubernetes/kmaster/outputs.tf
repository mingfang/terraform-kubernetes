output "subnet_ids" {
  value = module.subnets.ids
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "private_fqdn" {
  value = aws_route53_record.private.fqdn
}

output "public_fqdn" {
  value = aws_route53_record.public.fqdn
}
