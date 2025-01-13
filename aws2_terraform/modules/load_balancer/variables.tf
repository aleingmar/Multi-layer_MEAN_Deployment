variable "lb_name" {
  description = "Nombre del Load Balancer"
  default     = "AppLoadBalancer"
}

variable "lb_security_group_id" {
  description = "ID del grupo de seguridad asociado al Load Balancer"
}

variable "subnet_ids" {
  description = "IDs de las subnets asociadas al Load Balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID de la VPC asociada al Load Balancer"
}

variable "target_group_name" {
  description = "Nombre del grupo de destino"
  default     = "AppTargetGroup"
}

variable "web_server_ids" {
  description = "IDs de las instancias de los servidores web"
  type        = list(string)
}
