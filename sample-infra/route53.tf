# ===========
# Route53
# ===========
data "aws_route53_zone" "naked" {
  name = var.domain_name
}

# ================
# Route53 Record
# ===============
resource "aws_route53_record" "sample_route53" {
  zone_id = data.aws_route53_zone.naked.zone_id
  name    = var.fqdn_name
  type    = "A"
  alias {
    name                   = aws_alb.sample_alb.dns_name
    zone_id                = aws_alb.sample_alb.zone_id
    evaluate_target_health = true
  }
}

# ==================
# ACM Certificate
# ==================
# Certificate
resource "aws_acm_certificate" "main" {
  domain_name       = var.fqdn_name
  validation_method = "DNS"
}

# Certificate Validation
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.main_amc_c : record.fqdn]
}

resource "aws_route53_record" "main_amc_c" {
  for_each = {
    for d in aws_acm_certificate.main.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }
  zone_id         = data.aws_route53_zone.naked.id
  name            = each.value.name
  type            = each.value.type
  ttl             = 172800
  records         = [each.value.record]
  allow_overwrite = true
}