variable "domain_name" {}

variable origin_domain_name {}

variable route53_zone_id {}

resource "aws_cloudfront_distribution" web {
  enabled          = true
  retain_on_delete = false

  aliases = [
    "${var.domain_name}",
  ]

  origin {
    domain_name = "${var.origin_domain_name}"
    origin_id   = "web_origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"

      origin_ssl_protocols = [
        "SSLv3",
        "TLSv1",
      ]
    }
  }

  default_cache_behavior {
    target_origin_id       = "web_origin"
    compress               = true
    smooth_streaming       = false
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    forwarded_values {
      headers      = ["Host"]
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_route53_record" "root" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.web.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.web.hosted_zone_id}"
    evaluate_target_health = false
  }
}

output "cloudfront_id" {
  value = "${aws_cloudfront_distribution.web.id}"
}
