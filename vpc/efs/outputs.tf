output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "fqdn" {
  value = aws_route53_record.efs.fqdn
}
