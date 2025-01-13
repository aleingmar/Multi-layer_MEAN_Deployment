variable "vpc_id" {
  description = "ID de la VPC donde se crean los grupos de seguridad"
  type        = string
}

variable "web_server_name" {
  description = "Nombre base del grupo de seguridad para los servidores web"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks permitidos para tráfico de ingreso"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Cambiar según necesidades
}

variable "key_name" {
  description = "Nombre del par de claves SSH en AWS"
  type        = string
}