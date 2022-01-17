output "alb_sg_id" {
  value = aws_security_group.alb.id
}
output "dns_name" {
    value = aws_lb.alb.dns_name
}
output "alb_zone-id" {
value = aws_lb.alb.zone_id
}