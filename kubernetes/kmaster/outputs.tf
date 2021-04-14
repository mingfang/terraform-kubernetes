output "subnet_ids" {
  value = var.subnet_ids
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "kubeconfig_bucket" {
  value = aws_s3_bucket.keys.bucket
}