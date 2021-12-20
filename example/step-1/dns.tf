# DNS
data "aws_route53_zone" "legionx-com" {
  name = "legionx.com"
}

resource "aws_route53_zone" "public" {
  name = var.public_domain
}

resource "aws_route53_record" "public" {
  zone_id = data.aws_route53_zone.legionx-com.zone_id
  name    = var.public_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.public.name_servers
}