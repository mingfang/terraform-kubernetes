output "security-group-vpc" {
  value = aws_security_group.vpc
}

output "security-group-web" {
  value = aws_security_group.web
}