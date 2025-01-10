####################################################################################################
# CONFIGURACIÓN DE TERRAFORM PARA LOS PROVEEDORES AWS Y AZURE
####################################################################################################

# Azure Provider
provider "azurerm" {
  features {}
}


####################################################################################################
####################################################################################################
####################################################################################################
                                            #AZURE
####################################################################################################
####################################################################################################
####################################################################################################

####################################################################################################
# CONFIGURACIÓN DEL GRUPO DE RECURSOS PARA LA MÁQUINA VIRTUAL EN AZURE
####################################################################################################
# Crea un grupo de recursos donde se alojarán los recursos de Azure, como redes y máquinas virtuales.
resource "azurerm_resource_group" "example_rg" {
  #name     = "${var.instance_name}-rg" # El nombre del grupo de recursos se basa en la variable `instance_name`.
  name = var.azure_resource_group_name
  location = var.azure_region          # Define la región donde se desplegarán los recursos.
}



####################################################################################################
# CONFIGURACIÓN PARA EJECUTAR PACKER Y GENERAR LA IMAGEN EN AZURE
####################################################################################################
# Este recurso utiliza un comando local (en la máquina que ejecuta `terraform init`) para ejecutar Packer con las variables necesarias
# y generar la imagen basada en el archivo de configuración de Packer (`main.pkr.hcl`).
resource "null_resource" "packer_ami_azure" {

  depends_on = [azurerm_resource_group.example_rg] # Espera a que el recurso `azurerm_resource_group.example_rg` termine --> asegura que el grupo de recursos esté creado antes de intentar crear la imagen.
  # local-exec ejecuta un comando en la máquina que ejecuta Terraform.
  provisioner "local-exec" {
    # Este comando invoca Packer para construir una imagen personalizada usando las variables y configuraciones proporcionadas.
    command = "packer build -var azure_subscription_id=${var.azure_subscription_id} -var azure_client_id=${var.azure_client_id} -var azure_client_secret=${var.azure_client_secret} -var azure_tenant_id=${var.azure_tenant_id} -var-file=../azure_packer/variables.pkrvars.hcl ../azure_packer/main.pkr.hcl"
  }
}

####################################################################################################
# OBTENER LA ÚLTIMA IMAGEN CREADA EN AZURE
####################################################################################################
data "azurerm_image" "latest_azure_image" {
  depends_on          = [null_resource.packer_ami_azure] # Espera a que el provisioner `packer_ami_azure` termine --> asegura que la imagen sea creada antes de intentar recuperarla.
  name                = var.azure_image_name    # Busca la imagen por el nombre especificado en las variables.
  #resource_group_name = "${var.instance_name}-rg" # Especifica el grupo de recursos donde está ubicada la imagen.
  resource_group_name = var.azure_resource_group_name
}

####################################################################################################
# CONFIGURACIÓN DE LA RED VIRTUAL PARA LA MÁQUINA VIRTUAL EN AZURE
####################################################################################################
# Configura una red virtual para conectar recursos como la máquina virtual y la interfaz de red.
resource "azurerm_virtual_network" "example_vnet" {
  name                = "${var.azure_instance_name}-vnet"  # Nombre de la red virtual basado en `instance_name`.
  address_space       = ["10.0.0.0/16"]              # Espacio de direcciones IP asignado a la red.
  location            = azurerm_resource_group.example_rg.location # Ubicación de la red virtual (mismo lugar que el grupo de recursos).
  resource_group_name = azurerm_resource_group.example_rg.name     # Grupo de recursos asociado.
}

####################################################################################################
# CONFIGURACIÓN DE GRUPO DE SEGURIDAD PARA LA MÁQUINA VIRTUAL EN AZURE
####################################################################################################
resource "azurerm_network_security_group" "example_nsg" {

  name                = "${var.azure_instance_name}-nsg"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


####################################################################################################
# CONFIGURACIÓN DE LA SUBRED PARA LA MÁQUINA VIRTUAL EN AZURE
####################################################################################################
# Configura una subred dentro de la red virtual para conectar la máquina virtual.
resource "azurerm_subnet" "example_subnet" {


  name                 = "${var.azure_instance_name}-subnet"  # Nombre de la subred basado en `instance_name`.
  resource_group_name  = azurerm_resource_group.example_rg.name # Grupo de recursos asociado.
  virtual_network_name = azurerm_virtual_network.example_vnet.name # Nombre de la red virtual a la que pertenece esta subred.
  address_prefixes     = ["10.0.1.0/24"]                # Rango de direcciones IP asignado a esta subred.
  
}
# Configura una IP pública para la máquina virtual en Azure.
# resource "azurerm_public_ip" "example_public_ip" {

#   name                = "${var.azure_instance_name}-public-ip"
#   location            = azurerm_resource_group.example_rg.location
#   resource_group_name = azurerm_resource_group.example_rg.name
#   allocation_method   = "Dynamic" # Usa una IP pública dinámica
# }
resource "azurerm_public_ip" "example_public_ip" {

  name                = "${var.azure_instance_name}-public-ip"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  allocation_method   = "Static" # Cambia de Dynamic a Static
  sku                 = "Standard" # Mantén el SKU Standard si lo estás utilizando
}

####################################################################################################
# CONFIGURACIÓN DE LA INTERFAZ DE RED PARA LA MÁQUINA VIRTUAL EN AZURE
####################################################################################################
# Configura una interfaz de red para conectar la máquina virtual a la red y asignar una dirección IP dinámica.
resource "azurerm_network_interface" "example_nic" {

  name                = "${var.azure_instance_name}-nic"       # Nombre de la interfaz de red basado en `instance_name`.
  location            = azurerm_resource_group.example_rg.location # Ubicación de la interfaz de red (mismo lugar que el grupo de recursos).
  resource_group_name = azurerm_resource_group.example_rg.name      # Grupo de recursos asociado.
  
  ip_configuration {
    name                          = "internal"           # Nombre del perfil de configuración IP.
    subnet_id                     = azurerm_subnet.example_subnet.id # Subred a la que pertenece esta interfaz.
    private_ip_address_allocation = "Dynamic"            # Asigna dinámicamente una dirección IP privada.
    public_ip_address_id          = azurerm_public_ip.example_public_ip.id # Asocia la IP pública aquí
  }
  
}
# Asocia la interfaz de red con el grupo de seguridad de red.
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example_nic.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}


####################################################################################################
# CONFIGURACIÓN DE LA MÁQUINA VIRTUAL EN AZURE
####################################################################################################
# Este recurso lanza una máquina virtual usando la imagen recuperada en el bloque anterior.
# Asocia la interfaz de red y configura los discos y el perfil del sistema operativo.

resource "azurerm_virtual_machine" "example_vm" {


  name                  = "${var.azure_instance_name}-vm" # Nombre de la máquina virtual basado en `instance_name`.
  location              = azurerm_resource_group.example_rg.location # Ubicación de la máquina virtual (mismo lugar que el grupo de recursos).
  resource_group_name   = azurerm_resource_group.example_rg.name      # Grupo de recursos asociado.
  network_interface_ids = [azurerm_network_interface.example_nic.id] # Asocia la interfaz de red configurada previamente.
  vm_size               = var.azure_instance_type                    # Tipo de máquina virtual basado en la variable `azure_instance_type`.

  # Configuración del disco del sistema operativo.
  storage_os_disk {
    name              = "${var.azure_instance_name}-osdisk"  # Nombre del disco del sistema operativo basado en `instance_name`.
    caching           = "ReadWrite"                   # Configuración de caché para el disco.
    create_option     = "FromImage"                   # Indica que el disco se crea a partir de una imagen existente.
    managed_disk_type = "Standard_LRS"                # Tipo de disco administrado.
  }

  # Configuración para usar la imagen personalizada generada con Packer.
  storage_image_reference {
    id = data.azurerm_image.latest_azure_image.id     # Utiliza la imagen recuperada en el bloque `data.azurerm_image`.
  }
  ################## CONFIGURACION PARA ACCEDER POR CONTRASEÑA EN VEZ DE USAR PAR DE CLAVES (recomendado pero mas lio)
  # Configuración del perfil del sistema operativo.
  os_profile {
    computer_name  = "${var.azure_instance_name}"          # Nombre del equipo (máquina virtual).
    admin_username = var.azure_admin_username       # Usuario administrador para la conexión.
    admin_password = var.azure_admin_password       # Contraseña para el usuario administrador.
  }

  # Configuración adicional para sistemas operativos Linux.
  os_profile_linux_config {
    disable_password_authentication = false         # Permite autenticación con contraseña.
  }

  # Provisioner para ejecutar comandos en la VM
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.example_public_ip.ip_address
      user        = var.azure_admin_username
      password    = var.azure_admin_password
    }

    inline = [
      # Ejecuta app.js (trampilla un poco no he conseguido hacerlo directamente con la plantilla)
      # "pm2 start /home/ubuntu/backend/app.js"
      "pm2 start /home/ubuntu/app.js"
    ]
  }
}



####################################################################################################

# DESPLEGAR TERRAFORM

# Get-ChildItem Env: | Where-Object { $_.Name -like "PKR_VAR_*" } --> ver credenciales actuales de AWS en la consola de powershell
# Get-ChildItem Env: | Where-Object { $_.Name -like "ARM_*" } --> ver credenciales actuales DE AZURE en la consola de powershell

######## EL BUENO
# terraform init --> Inicializa el directorio de trabajo
# terraform apply -var "azure_subscription_id=$env:ARM_SUBSCRIPTION_ID" ` -var "azure_client_id=$env:ARM_CLIENT_ID" ` -var "azure_client_secret=$env:ARM_CLIENT_SECRET" ` -var "azure_tenant_id=$env:ARM_TENANT_ID"
# terraform destroy -var "azure_subscription_id=$env:ARM_SUBSCRIPTION_ID" ` -var "azure_client_id=$env:ARM_CLIENT_ID" ` -var "azure_client_secret=$env:ARM_CLIENT_SECRET" ` -var "azure_tenant_id=$env:ARM_TENANT_ID"



# terraform destroy -var "azure_subscription_id=$env:ARM_SUBSCRIPTION_ID" ` -var "azure_client_id=$env:ARM_CLIENT_ID" ` -var "azure_client_secret=$env:ARM_CLIENT_SECRET" ` -var "azure_tenant_id=$env:ARM_TENANT_ID" && terraform apply -var "azure_subscription_id=$env:ARM_SUBSCRIPTION_ID" ` -var "azure_client_id=$env:ARM_CLIENT_ID" ` -var "azure_client