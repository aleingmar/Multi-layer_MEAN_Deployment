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