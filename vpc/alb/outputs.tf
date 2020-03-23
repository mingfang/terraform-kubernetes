output "target_group_arns" {
  value = aws_alb_target_group.atg.*.arn
}

output "alb_arn" {
  value = join(" ", aws_alb.alb.*.arn)
}

output "private_fqdn" {
  value = join(" ", aws_route53_record.private.*.fqdn)
}

output "public_fqdns" {
  value = aws_route53_record.public.*.fqdn
}