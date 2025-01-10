# Plantilla de Packer para crear una imagen para AWS con Ubuntu 20.04, Nginx y Node.js

########################################################################################################################
# PLUGINS: Define los plugins necesarios para la plantilla
# Para descargar el plugin necesario para la plantilla, levantar la imagen en Azure y aws
packer {
  required_plugins {
    azure-arm = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/azure"
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
# a las credenciales de AWS y Azureles voy a asignar valores por defecto, por si no se pasan al ejecutar el comando

# VARIABLES: Define las variables necesarias para la plantilla
variable "azure_image_name" { description = "Nombre de la imagen para Azure" }
variable "azure_region" { description = "Región de Azure" }
variable "azure_instance_type" { description = "Tipo de instancia en Azure"  }
variable "azure_resource_group_name" { description = "Nombre del grupo de recursos de Azure" }
variable "environment" { description = "Entorno de la aplicación" }

# CREDENCIALES (no hace falta definirlas creo)
variable "azure_subscription_id" { 
  description = "ID de la suscripción de Azure" 
  default = "default"
}
variable "azure_client_id" { 
  description = "ID de la aplicación (cliente) en Azure" 
  default = "default"
}
variable "azure_client_secret" { 
  description = "Clave secreta de la aplicación (cliente) en Azure" 
  default = "default"
}
variable "azure_tenant_id" { 
  description = "ID del inquilino en Azure" 
  default = "default"
}


#######################################################################################################################
# AZURE BUILDER
#######################################################################################################################
# BUILDER: Define cómo se construye la AMI en AWS y azure
# source{}--> define el sistema base sobre el que quiero crear la imagen (ISO ubuntu) y el proveeedor para el que creamos la imagen 
# (tecnologia con la que desplegará la imagen) --> AMAZON y azure

source "azure-arm" "azure_builder" {
  subscription_id                = var.azure_subscription_id
  client_id                      = var.azure_client_id
  client_secret                  = var.azure_client_secret
  tenant_id                      = var.azure_tenant_id

  managed_image_name             = var.azure_image_name
  managed_image_resource_group_name = var.azure_resource_group_name
  location                       = var.azure_region
  ssh_username = "ubuntu" # usuario para conectarse a la instancia y realizar todas las operaciones

  vm_size                        = var.azure_instance_type # instancia equivalente a t2.micro de aws
  os_type                        = "Linux"
  image_publisher                = "Canonical"
  image_offer                    = "UbuntuServer"
  image_sku                      = "18.04-LTS" # Cambia al SKU disponible
  image_version                  = "latest"
  azure_tags = {
    environment = var.environment
  }
}


#######################################################################################################################
# PROVISIONERS (SAME FOR BOTH CLOUD (AWS AND AZURE))
#######################################################################################################################
# PROVISIONERS: Configura el sistema operativo y la aplicación
# build{}: Describe cómo se construirá la imagen --> Definir los provisioners para instalar y configurar software
#######################################################################3
# PROVISIONER para Azure usamos Ansible

build {
  name    = "ansible-frontend-backend-azure"
  sources = ["source.azure-arm.azure_builder"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y ansible"
    ]
  }
  provisioner "file" { # Pasamos los ficheros a la instancia para que ansible los puedo manipular (ansible esta en la instancia)
  source      = "../packer/provisioners/app.js"
  destination = "/tmp/app.js"
}

  provisioner "file" {
  source      = "../packer/provisioners/nginx_default.conf"
  destination = "/tmp/nginx_default.conf"
  }
#    # Copiar la carpeta completa del proyecto Angular a la instancia
#    provisioner "file" {
#     source      = "../packer/provisioners/dist" # Ruta local donde está la carpeta dist
#     destination = "/tmp/dist"                  # Ruta en la máquina virtual
# }


  provisioner "ansible-local" {
    playbook_file = "../packer/provisioners/provision.yml" #perspectiva desde el terraform apply 
  }
}
