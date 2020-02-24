variable "domain_name" {
  default = ""
}

variable "subject_alternative_names" {
  default = []
  type    = list(string)
}

variable "zone_id" {
  default = ""
}

variable "enable" {
  default = true
}

resource "aws_acm_certificate" "cert" {
  count                     = var.enable ? 1 : 0
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "cert_validation" {
  count                   = var.enable ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [aws_route53_record.cert_record[0].fqdn]
}

resource "aws_route53_record" "cert_record" {
  count   = var.enable ? 1 : 0
  name    = aws_acm_certificate.cert[0].domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.cert[0].domain_validation_options[0].resource_record_type
  zone_id = var.zone_id
  records = [aws_acm_certificate.cert[0].domain_validation_options[0].resource_record_value]
  ttl     = 60
}

output "arn" {
  value = join(" ", aws_acm_certificate.cert.*.arn)
}

