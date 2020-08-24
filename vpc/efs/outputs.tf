output "this" {
  value = aws_efs_file_system.efs
}

output "private_fqdn" {
  value = aws_route53_record.efs.fqdn
}

output "mount_target_client_security_group_id" {
  value = aws_security_group.mount_target_client.id
}