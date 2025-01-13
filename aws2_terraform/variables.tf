###################################### Network
variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  default     = "172.31.16.0/24"
}

variable "vpc_name" {
  description = "Nombre de la VPC"
  default     = "CustomVPC"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block para la primera subred pública"
  default     = "172.31.16.0/25"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block para la segunda subred pública"
  default     = "172.31.16.128/25"
}

variable "availability_zone_1" {
  description = "Zona de disponibilidad para la primera subred pública"
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "Zona de disponibilidad para la segunda subred pública"
  default     = "us-east-1b"
}

####################################### Security
variable "web_sg_name" {
  description = "Nombre del grupo de seguridad para servidores web"
  default     = "WebServerSG"
}

variable "mongodb_sg_name" {
  description = "Nombre del grupo de seguridad para MongoDB"
  default     = "MongoDBSG"
}

####################################### Compute
variable "ami_id" {
  description = "AMI ID para las instancias EC2"
}

variable "instance_type" {
  description = "Tipo de instancia"
  default     = "t2.micro"
}

variable "web_server_count" {
  description = "Número de instancias de servidores web"
  default     = 2
}

variable "web_server_name" {
  description = "Nombre base para los servidores web"
  default     = "WebServer"
}

variable "mongodb_name" {
  description = "Nombre de la instancia de MongoDB"
  default     = "MongoDB"
}

####################################### Load Balancer

variable "lb_name" {
  description = "Nombre del Load Balancer"
  default     = "AppLoadBalancer"
}

variable "target_group_name" {
  description = "Nombre del grupo de destino"
  default     = "AppTargetGroup"
}