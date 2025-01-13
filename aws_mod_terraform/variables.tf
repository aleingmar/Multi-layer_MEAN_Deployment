############################################
# AWS Configuration
############################################

variable "aws_region" {
  description = "Región de AWS utilizada por todos los módulos"
  type        = string
  default     = "us-east-1" # Cambiar si es necesario
}

variable "aws_access_key" {
  description = "Clave de acceso de AWS para autenticación"
  type        = string
  #sensitive   = true
}

variable "aws_secret_key" {
  description = "Clave secreta de AWS para autenticación"
  type        = string
  #sensitive   = true
}

variable "aws_session_token" {
  description = "Token de sesión de AWS para autenticación temporal"
  type        = string
  #sensitive   = true
}

############################################
# Security
############################################

variable "key_name" {
  description = "Nombre del par de claves SSH generado en el módulo de seguridad"
  type        = string
}

# variable "ssh_private_key" {
#   description = "Clave privada generada en el módulo de seguridad para SSH"
#   type        = string
#   sensitive   = true
# }

############################################
# Instances
############################################

# variable "web_server_ami" {
#   description = "AMI utilizada para los servidores web (generada por Packer)"
#   type        = string
# }

# variable "mongodb_ami" {
#   description = "AMI utilizada para la instancia de MongoDB (generada por Packer)"
#   type        = string
# }
