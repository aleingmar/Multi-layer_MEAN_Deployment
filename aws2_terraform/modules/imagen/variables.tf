variable "ami_name" {
  default     = "mi-ami"
  description = "Nombre base de la AMI"
}

### CREDENCIALES

variable "aws_access_key" {
  description = "Clave de acceso de AWS"
  default = "TU_ACCESS"
}

variable "aws_secret_key" {
  description = "Clave secreta de AWS"
    default = "TU_SECRET"
}

variable "aws_session_token" {
  description = "Token de sesión de AWS"
  default = "TU_SESSION"
}