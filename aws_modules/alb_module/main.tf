data "aws_availability_zones" "available" {}
resource "aws_security_group" "alb" {
  vpc_id = "${var.vpc_id}"
  name   = "${var.env}-alb"
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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-alb"
  }
}
resource "aws_lb" "alb"{
load_balancer_type = "application"
security_groups = [aws_security_group.alb.id]
subnets = var.public_subnet_ids
enable_cross_zone_load_balancing = true

tags = {
 Name = "${var.env}-alb"
 }
}
resource "aws_lb_target_group" "alb-tg" {
  name     = "${var.env}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_autoscaling_attachment" "target" {
  autoscaling_group_name = var.asg_name
  alb_target_group_arn   = aws_lb_target_group.alb-tg.arn
}

resource "aws_lb_listener" "https_listeners" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-2:275786180996:certificate/536f6431-4e27-463a-a7af-3ee24ec54596"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

resource "aws_lb_listener" "alb_80_redirect_to_443" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}