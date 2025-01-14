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

  # Configuración de health check
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  # Configuración de Sticky Sessions
  # Con esto conseguimos que el balanceador recuerde que instancia mando el index.html y redirija las peticiones de sus rcursos a la misma instancia
  # Si no me daba un gran problema de inconsistencia en la carga de los recursos
  # 5s deberia ser mas q de sobra
  stickiness {
    type            = "lb_cookie" # Usamos cookies gestionadas por el ALB
    cookie_duration = 5          # Duración de 10 segundos
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
  count             = var.instance_target_count
  target_group_arn  = aws_lb_target_group.app_target_group.arn
  target_id         = var.target_ids[count.index]
  port              = var.target_port
}
