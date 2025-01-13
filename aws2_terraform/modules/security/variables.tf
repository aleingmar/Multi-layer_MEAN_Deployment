variable "vpc_id" {
  description = "ID de la VPC donde se crearán los grupos de seguridad"
}

variable "web_sg_name" {
  description = "Nombre del grupo de seguridad para el servidor web"
  default     = "web-server-sg"
}

variable "mongodb_sg_name" {
  description = "Nombre del grupo de seguridad para MongoDB"
  default     = "mongodb-sg"
}