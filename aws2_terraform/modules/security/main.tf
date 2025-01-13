resource "aws_security_group" "web_server_sg" {
  vpc_id      = var.vpc_id
  name        = var.web_sg_name
  description = "Grupo de seguridad para las instancias EC2 del servidor web"

  ingress {
    description      = "Permitir tráfico HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Permitir tráfico HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Permitir acceso SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # En entornos reales, limita este rango
  }

  ingress {
    description      = "Permitir ICMP (Ping)"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.web_sg_name
  }
}

resource "aws_security_group" "mongodb_sg" {
  vpc_id      = var.vpc_id
  name        = var.mongodb_sg_name
  description = "Grupo de seguridad para MongoDB"

  ingress {
    description      = "Permitir tráfico desde el backend"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Cambia esto según las necesidades
  }

  ingress {
    description      = "Permitir acceso SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Permitir ICMP (Ping)"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.mongodb_sg_name
  }
}
