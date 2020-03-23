
resource "aws_acm_certificate" "cert" {
  count                     = var.enable ? 1 : 0
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
}

/*
todo: HACK!
Expect domain_name to be bare, example.com and first subject_alternative_names to be wild card, *.example.com.
The problem is domain_validation_options.resource_record_value is same for example.com and *.example.com, casuing a duplicate record error.
Hack is to skip the first record, hence length(var.subject_alternative_names) and count.index + 1 below.
Ideal the correct way is length(var.subject_alternative_names) + 1 and count.index instead.
Not the same but related issue here https://github.com/terraform-providers/terraform-provider-aws/issues/8531
*/
resource "aws_route53_record" "cert_record" {
  count   = length(var.subject_alternative_names)
  name    = aws_acm_certificate.cert[0].domain_validation_options[count.index + 1].resource_record_name
  type    = aws_acm_certificate.cert[0].domain_validation_options[count.index + 1].resource_record_type
  zone_id = var.zone_id
  records = [aws_acm_certificate.cert[0].domain_validation_options[count.index + 1].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  count                   = var.enable ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = aws_route53_record.cert_record.*.fqdn
}
