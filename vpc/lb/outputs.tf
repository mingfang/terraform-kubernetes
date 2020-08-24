output "lb" {
  value = aws_lb.lb
}

output "target_group_arns" {
  value = aws_lb_target_group.atg.*.arn
}

output "fqdn" {
  value = join(" ", aws_route53_record.route53_records.*.fqdn)
}