data "aws_route53_zone" "naked" {
  name = var.domain_name
}

resource "aws_route53_record" "sample_route53" {
  zone_id = data.aws_route53_zone.naked.zone_id
  name    = data.aws_route53_zone.naked.name
  type    = "A"
  alias {
    name                   = aws_alb.sample_alb.dns_name
    zone_id                = aws_alb.sample_alb.zone_id
    evaluate_target_health = true
  }
}