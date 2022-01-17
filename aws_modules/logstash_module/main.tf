resource "aws_security_group" "log-nodes" {
  vpc_id = "${var.vpc_id}"
  name   = "${var.env}-log"
  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["${var.vpc_cidr_block}"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-log"
  }
}

resource "aws_launch_template" "logstash" {
  name = "logstash"
  disable_api_termination = true
  image_id               = "ami-001089eb624938d9f"
  instance_type          = "${var.instance_type}"
  key_name               = "key-ohio"
  vpc_security_group_ids = [aws_security_group.log-nodes.id]
  iam_instance_profile   {
     name   = "DescribeInstances"
     }
  user_data = base64encode(templatefile("${path.module}/logstash.sh", {
    version = var.version-elk
  }))
}
resource "aws_autoscaling_group" "logstash" { 
  name                = "log"
  vpc_zone_identifier = var.public_subnet_ids
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2

  launch_template {
    id      = aws_launch_template.logstash.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "log"
    propagate_at_launch = true
  }
}