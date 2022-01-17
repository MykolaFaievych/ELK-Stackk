resource "aws_route53_zone" "elk" {
  name = "mfaie-ocg4.link"

  tags = {
    Environment = "elk"
  }
}
resource "aws_route53_record" "elk" {
  zone_id = "Z0758083WQW1OFEF6BBQ"
  name    = "elk.mfaie-ocg4.link"
  type    = "A"

  alias {
    name                   = "${var.alb-dns_name}"
    zone_id                = "${var.alb-zone_id}"
    evaluate_target_health = true
  }
}