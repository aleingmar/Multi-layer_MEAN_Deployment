# Credenciales de AWS
variable "aws_access_key" {
  description = "Clave de acceso de AWS"
  type        = string
}

variable "aws_secret_key" {
  description = "Clave secreta de AWS"
  type        = string
}

variable "aws_session_token" {
  description = "Token de sesión de AWS"
  type        = string
}

# Configuración de Packer
variable "packer_var_file" {
  description = "Ruta al archivo de variables para Packer"
  type        = string
}

variable "packer_template_file" {
  description = "Ruta al archivo de plantilla de Packer"
  type        = string
}

# AMI
variable "ami_name" {
  description = "Nombre base de la AMI creada por Packer"
  type        = string
}
