resource "aws_security_group" "kibana" {
  vpc_id = "${var.vpc_id}"
  name   = "${var.env}+kibana"
  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-kibana"
  }
}

resource "aws_launch_template" "kibana" {
  name = "kibana"
  disable_api_termination = true
  image_id = "ami-001089eb624938d9f"
  instance_type = "${var.instance_type}"
  key_name = "key-ohio"
  vpc_security_group_ids = [aws_security_group.kibana.id]
  iam_instance_profile   {
     name = "DescribeInstances"
     }
  user_data = base64encode(templatefile("${path.module}/kibana.sh", {
    version = var.version-elk
  }))
}
resource "aws_autoscaling_group" "kibana" {  
  name                = "kibana"
  vpc_zone_identifier = var.public_subnet_ids
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.kibana.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "kibana"
    propagate_at_launch = true
  }
}