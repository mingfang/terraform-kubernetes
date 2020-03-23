output "arn" {
  value = join(" ", aws_acm_certificate.cert.*.arn)
}
