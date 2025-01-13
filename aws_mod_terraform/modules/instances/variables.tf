# General
variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
}

variable "key_name" {
  description = "Nombre del par de claves SSH en AWS"
  type        = string
}

variable "ssh_private_key" {
  description = "Clave privada para conexión SSH"
  type        = string
}

# Web Servers
variable "web_server_count" {
  description = "Número de instancias de servidores web"
  type        = number
  default     = 2
}

variable "web_server_ami" {
  description = "AMI para los servidores web"
  type        = string
}

variable "web_server_subnet_id" {
  description = "ID de la subnet para los servidores web"
  type        = string
}

variable "web_server_private_ip_base" {
  description = "Base para las IPs privadas de los servidores web (ej: 172.31.16)"
  type        = string
}

variable "web_server_security_group_id" {
  description = "ID del grupo de seguridad para los servidores web"
  type        = string
}

variable "web_server_instance_name" {
  description = "Nombre base de las instancias de servidores web"
  type        = string
}

# MongoDB
variable "mongodb_ami" {
  description = "AMI para MongoDB"
  type        = string
}

variable "mongodb_subnet_id" {
  description = "ID de la subnet para MongoDB"
  type        = string
}

variable "mongodb_private_ip" {
  description = "IP privada para MongoDB"
  type        = string
}

variable "mongodb_security_group_id" {
  description = "ID del grupo de seguridad para MongoDB"
  type        = string
}

variable "ssh_private_key" {
  description = "Clave privada SSH generada"
  type        = string
  sensitive   = true
}