variable "ami_id" {
  description = "AMI ID para las instancias EC2"
}

variable "instance_type" {
  description = "Tipo de instancia para las EC2"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre del par de claves para las instancias EC2"
}

variable "private_key" {
  description = "Clave privada para conectar a las instancias EC2"
}

variable "web_server_count" {
  description = "Número de instancias de servidores web"
  default     = 2
}

variable "web_server_name" {
  description = "Nombre base para las instancias de servidores web"
  default     = "WebServer"
}

variable "web_server_eni_ids" {
  description = "IDs de las ENIs asociadas a los servidores web"
  type        = list(string)
}

variable "web_server_public_ips" {
  description = "IPs públicas de las instancias de servidores web"
  type        = list(string)
}

variable "mongodb_name" {
  description = "Nombre de la instancia MongoDB"
  default     = "MongoDB"
}

variable "mongodb_eni_id" {
  description = "ID de la ENI asociada a MongoDB"
}

variable "mongodb_public_ip" {
  description = "IP pública de la instancia MongoDB"
}
