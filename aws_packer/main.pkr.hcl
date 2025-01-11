# Plantilla de Packer para crear una imagen para AWS con Ubuntu 20.04, Nginx y Node.js

########################################################################################################################
# PLUGINS: Define los plugins necesarios para la plantilla
packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

#######################################################################################################################
# VARIABLES
#######################################################################################################################
variable "aws_region" { description = "Región de AWS" }
variable "ami_name" { description = "Nombre de la AMI generada" }
variable "instance_type" { description = "Tipo de instancia de AWS" }
variable "project_name" { description = "Nombre del proyecto" }
variable "environment" { description = "Entorno del proyecto (dev, test, prod)" }

# Credenciales de AWS
variable "aws_access_key" { 
  description = "Clave de acceso de AWS" 
  default = "default"
}
variable "aws_secret_key" { 
  description = "Clave secreta de AWS" 
  default = "default"
}
variable "aws_session_token" { 
  description = "Token de sesión de AWS" 
  default = "default"
}

#######################################################################################################################
# AWS BUILDER
#######################################################################################################################
source "amazon-ebs" "aws_builder" {
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  token         = var.aws_session_token
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Propietario de las AMIs de Ubuntu (Canonical)
    most_recent = true
  }

  instance_type = var.instance_type
  ssh_username  = "ubuntu"
  ami_name      = var.ami_name

  tags = {
    Name = "Packer-Builder"
  }
}

#######################################################################################################################
# PROVISIONERS
#######################################################################################################################
build {
  name    = "comandos-cloud-node-nginx"
  sources = ["source.amazon-ebs.aws_builder"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y ansible"
    ]
  }
  provisioner "file" { # Pasamos los ficheros a la instancia para que ansible los puedo manipular (ansible esta en la instancia)
  source      = "../aws_packer/provisioners/app.js"
  destination = "/tmp/app.js"
}

  provisioner "file" {
  source      = "../aws_packer/provisioners/nginx_default.conf"
  destination = "/tmp/nginx_default.conf"
  }

  ################################# PROVISION DE APP DE ANSIBLE
  provisioner "file" {
  source      = "../aws_packer/provisioners/angular-app/app.component.ts"
  destination = "/tmp/app.component.ts"
  }
  provisioner "file" {
  source      = "../aws_packer/provisioners/angular-app/app.modules.ts"
  destination = "/tmp/app.modules.ts"
  }
  provisioner "file" {
  source      = "../aws_packer/provisioners/angular-app/environment.ts"
  destination = "/tmp/app.environment.ts"
  }
  #############################################33

  provisioner "ansible-local" {
    playbook_file = "../aws_packer/provisioners/provision.yml" #perspectiva desde el terraform apply 
  }
}