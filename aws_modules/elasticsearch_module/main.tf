resource "aws_security_group" "es-nodes" {
  vpc_id = "${var.vpc_id}"
  name   = "${var.env}+es"
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
    Name = "${var.env}-es"
  }
}

resource "aws_launch_template" "elasticsearch" {
  name = "elasticsearch"
  disable_api_termination = true
  image_id                = "ami-001089eb624938d9f"
  instance_type           = "${var.instance_type}"
  key_name                = "key-ohio"
  vpc_security_group_ids  = [aws_security_group.es-nodes.id]
  iam_instance_profile   {
     name = "DescribeInstances"
     }
  user_data = base64encode(templatefile("${path.module}/elasticsearch.sh", {
    version = var.version-elk
  }))
}
resource "aws_autoscaling_group" "elasticsearch" { 
  name                = "es"
  vpc_zone_identifier = var.private_subnet_ids
  desired_capacity    = 6
  max_size            = 6
  min_size            = 6

  launch_template {
    id      = aws_launch_template.elasticsearch.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "es"
    propagate_at_launch = true
  }
}