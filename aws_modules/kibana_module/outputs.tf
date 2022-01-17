output "kibana_sg_id" {
  value = aws_security_group.kibana.id
}
output "asg_name" {
  value = aws_autoscaling_group.kibana.name
}