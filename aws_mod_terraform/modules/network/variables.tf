# VPC
variable "vpc_cidr_block" {
  description = "CIDR block para la VPC"
  type        = string
}

variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
}

# Subnets
variable "subnet_1_cidr" {
  description = "CIDR block para la primera subnet"
  type        = string
}

variable "subnet_1_az" {
  description = "Zona de disponibilidad para la primera subnet"
  type        = string
}

variable "subnet_1_name" {
  description = "Nombre de la primera subnet"
  type        = string
}

variable "subnet_2_cidr" {
  description = "CIDR block para la segunda subnet"
  type        = string
}

variable "subnet_2_az" {
  description = "Zona de disponibilidad para la segunda subnet"
  type        = string
}

variable "subnet_2_name" {
  description = "Nombre de la segunda subnet"
  type        = string
}

# Internet Gateway
variable "igw_name" {
  description = "Nombre del Internet Gateway"
  type        = string
}

# Route Table
variable "route_table_name" {
  description = "Nombre de la Route Table"
  type        = string
}
