output "public_subnet_ids" {
  value = module.public_subnets.ids
}

output "nat_gateway_ids" {
  value = module.nats.ids
}

output "nat_gateway_public_ips" {
  value = module.nats.public_ips
}

output "route53_private" {
  value = aws_route53_zone.private
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

