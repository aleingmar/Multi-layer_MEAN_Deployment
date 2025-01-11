####################################################################################################
# CONFIGURACIÓN DE TERRAFORM PARA LOS PROVEEDORES AWS Y AZURE
####################################################################################################

# AWS Provider
provider "aws" {
  region = var.aws_region
}

#################################################################################################
#################################################################################################
#################################################################################################
                                            #AWS
####################################################################################################
####################################################################################################
####################################################################################################
# IMPORTANTE --> VARIABLE COUNT
# count es una variable que te dice el numero de recursos a levantar en los tipo RESOURCES--> si es uno levantara 1 y si es 0, pues 0. (si fuese 3 levantaria 3 recursos)
# cuando se usa count, se debe usar el indice para acceder a los recursos, por ejemplo aws_instance.web_server.id

# RECURSO PARA EJECUTAR PACKER Y GENERAR LA AMI
# Este recurso utiliza un comando local (en la maquina que ejecuta terraform init) para ejecutar Packer con las variables necesarias
# y generar la AMI basada en el archivo de configuración de Packer (main.pkr.hcl).
resource "null_resource" "packer_ami" {
  # local-exec ejecuta un comando en la máquina que ejecuta Terraform.
  provisioner "local-exec" {
    # Este comando invoca Packer para construir una AMI personalizada usando las variables y configuraciones proporcionadas.
    # usa solo ese provisioner y builder comandos-cloud-node-nginx.amazon-ebs.aws_builder
    command = "packer build -var aws_access_key=${var.aws_access_key} -var aws_secret_key=${var.aws_secret_key} -var aws_session_token=${var.aws_session_token} -var-file=../aws_packer/variables.pkrvars.hcl ../aws_packer/main.pkr.hcl"
    #command = "packer build -var azure_subscription_id=${var.azure_subscription_id} -var azure_client_id=${var.azure_client_id} -var azure_client_secret=${var.azure_client_secret} -var azure_tenant_id=${var.azure_tenant_id} -var-file=../azure_packer/variables.pkrvars.hcl ../azure_packer/main.pkr.hcl"
  }
}

####################################################################################################
# OBTENER LA ÚLTIMA AMI CREADA
####################################################################################################
data "aws_ami" "latest_ami" {
  
  depends_on = [null_resource.packer_ami] # Espera a que el provisioner "packer_ami" termine --> asegura que la AMI sea creada antes de intentar recuperarla.
  most_recent = true                      # Selecciona siempre la AMI más reciente.
  filter {
    name   = "name"                       # Filtra por el nombre de la AMI.
    values = ["${var.ami_name}*"]         # Busca nombres que coincidan parcialmente con el valor de la variable `ami_name`.
  }
  owners = ["self"]                       # Limita la búsqueda a las AMIs creadas por el propietario actual.
}

####################################################################################################
# OBTENER LA VPC POR DEFECTO (configuración de red virtual)
####################################################################################################
data "aws_vpc" "default" {
  
  default = true # Recupera la VPC predeterminada asociada a la cuenta AWS.
}

####################################################################################################
# CONFIGURACIÓN DEL GRUPO DE SEGURIDAD PARA LA INSTANCIA EC2
####################################################################################################
# Intentar buscar un grupo de seguridad existente basado en su nombre y VPC.
# data "aws_security_group" "existing_sg" {
#   
#   # Filtro para buscar un grupo de seguridad por su nombre.
#   filter {
#     name   = "group-name"
#     values = ["${var.instance_name}-sg"] # Nombre basado en la variable `instance_name`.
#   }
#   # Filtro para asegurarse de que pertenece a la VPC predeterminada.
#   # filter {
#   #   name   = "vpc-id"
#   #   values = [data.aws_vpc.default.id] # ID de la VPC predeterminada.
#   # }
#   filter {
#     name   = "vpc-id"
#     values = length(data.aws_vpc.default) > 0 ? [data.aws_vpc.default.id] : []
#   }

# }
resource "aws_security_group" "web_server_sg" {
  # Crear un nuevo grupo de seguridad solo si no existe uno con el nombre especificado.
  # Condición para crear o no el recurso. (si no existe count=1, se crea uno nuevo), try es para que no falle si no hay
  
  #count = length(try(data.aws_security_group.existing_sg, [])) == 0 ? 1 : 0
  name        = "${var.instance_name}-sg" # El nombre del grupo de seguridad se basa en el nombre de la instancia.
  description = "Grupo de seguridad para la instancia EC2" # Descripción del grupo.
  #vpc_id      = data.aws_vpc.default.id  # Asocia este grupo de seguridad a la VPC predeterminada.
  vpc_id      = length(data.aws_vpc.default) > 0 ? data.aws_vpc.default.id : null
  
  #ingress --> trafico de entrada
  #egrress --> trafico de salida
  # Reglas de ingreso para permitir tráfico HTTP.
  ingress {
    description      = "Permitir trafico HTTP"
    from_port        = 80               # Puerto de entrada (HTTP).
    to_port          = 80
    protocol         = "tcp"            # Protocolo TCP.
    cidr_blocks      = ["0.0.0.0/0"]    # Permite tráfico desde cualquier dirección IP.
  }

  # Reglas de ingreso para permitir tráfico HTTPS.
  ingress {
    description      = "Permitir trafico HTTPS"
    from_port        = 443              # Puerto de entrada (HTTPS).
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    # Permite tráfico desde cualquier dirección IP.
  }

  # Reglas de ingreso para permitir acceso SSH.
  ingress {
    description      = "Permitir acceso SSH"
    from_port        = 22               # Puerto de entrada (SSH).
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    # Permite acceso desde cualquier dirección IP (debe ser restringido en entornos reales).
  }

  # Reglas de egreso para permitir todo el tráfico saliente.
  egress {
    from_port   = 0                     # Puerto de salida (todos).
    to_port     = 0
    protocol    = "-1"                  # Permite todos los protocolos.
    cidr_blocks = ["0.0.0.0/0"]         # Permite tráfico hacia cualquier dirección IP.
  }
}
###################################################
# GENERA EL PAR DE CLAVES Y SE LO PASA A AWS
##################################################
# Generar un par de claves SSH automáticamente
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Registrar la clave pública en AWS
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name # Nombre de la clave en AWS
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Guardar la clave privada localmente
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/id_rsa"
}

####################################################################################################
# CONFIGURACIÓN DE LA INSTANCIA EC2
####################################################################################################
# Este recurso lanza una instancia EC2 usando la AMI recuperada en el bloque anterior.
# Asocia el grupo de seguridad a la instancia EC2 y configura la conexión SSH.

resource "aws_instance" "web_server" {
  ## IMPORTANTE--> Condicion para desplegar en AWS, si al hacer el terraform apply el valor del target es aws o both, se desplegara en aws
  
  ami                   = data.aws_ami.latest_ami.id # Usa la AMI más reciente creada con Packer.
  instance_type         = var.instance_type          # Define el tipo de instancia basado en la variable `instance_type`.
  key_name              = aws_key_pair.generated_key.key_name # Especifica la clave SSH para acceso remoto.
  vpc_security_group_ids = [aws_security_group.web_server_sg.id] # Asocia el grupo de seguridad configurado.

  tags = {
    Name = var.instance_name # Etiqueta la instancia con el nombre especificado en la variable.
  }

  # Configuración para conectar a la instancia vía SSH.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/id_rsa") # Usar la clave privada guardada localmente
    host        = self.public_ip
  }

  # Provisionador remoto para ejecutar comandos en la instancia EC2.
  provisioner "remote-exec" {
    inline = [
      "echo 'La instancia está configurada correctamente.'" # Muestra un mensaje simple para verificar que la instancia está configurada.
    ]
  }
}

################################################################################################################

# terraform apply -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token" 
# terraform destroy -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token"