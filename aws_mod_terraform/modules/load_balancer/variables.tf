variable "lb_name" {
  description = "Nombre del Load Balancer"
  type        = string
}

variable "security_groups" {
  description = "Lista de grupos de seguridad asociados al Load Balancer"
  type        = list(string)
}

variable "subnets" {
  description = "Lista de subnets asociadas al Load Balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID de la VPC donde se despliega el Load Balancer"
  type        = string
}

variable "listener_port" {
  description = "Puerto del listener"
  type        = number
  default     = 80
}

variable "target_port" {
  description = "Puerto del Target Group y los Attachments"
  type        = number
  default     = 80
}

variable "instance_count" {
  description = "Cantidad de instancias para el Target Group Attachment"
  type        = number
}

variable "target_ids" {
  description = "Lista de IDs de las instancias objetivo"
  type        = list(string)
}
