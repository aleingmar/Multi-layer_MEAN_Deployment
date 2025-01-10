
############################################
# AZURE
######º#####################################

###############CREDENCIALES
variable "azure_subscription_id" { description = "Azure subscription ID" }
variable "azure_client_id" { description = "Azure client ID" }
variable "azure_client_secret" { description = "Azure client secret" }
variable "azure_tenant_id" { description = "Azure tenant ID" }
###############################

variable "azure_region" { 
  default = "East US" 
  description = "Azure region" 
}
variable "azure_instance_type" { 
  default = "Standard_B1ms" 
  description = "Azure instance type" 
  }
variable "azure_admin_username" { 
  default = "adminuser" 
  description = "Admin username for Azure VM" 
}
variable "azure_admin_password" { description = "Admin password for Azure VM" }
variable "azure_image_name" { description = "Name of the Azure image created by Packer" }
variable "azure_resource_group_name" { description = "Name of the Azure resource group" }
variable "azure_instance_name" { description = "Name of the Azure instance" }