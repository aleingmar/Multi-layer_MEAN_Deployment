resource "aws_lb" "app_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  tags = {
    Name = var.lb_name
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name         = "${var.lb_name}-target-group"
  port         = var.target_port
  protocol     = "HTTP"
  vpc_id       = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.lb_name}-target-group"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "web_server_attachment" {
  count             = var.instance_count
  target_group_arn  = aws_lb_target_group.app_target_group.arn
  target_id         = var.target_ids[count.index]
  port              = var.target_port
}