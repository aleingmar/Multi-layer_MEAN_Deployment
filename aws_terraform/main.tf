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
# me fijo en las subreedes que tiene la vpc por defecto
data "aws_subnet" "default" {
  filter {
    name   = "vpc-id"
    values = ["vpc-06cb256503c358a72"]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]
  }
}


####################################################################################################
# CONFIGURACIÓN DEL GRUPO DE SEGURIDAD PARA LA INSTANCIA EC2
####################################################################################################
# Este recurso crea un grupo de seguridad para la instancia EC2.
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
 # Permitir ICMP (Ping)
  ingress {
    description      = "Permitir ICMP (Ping)"
    from_port        = -1                # Todos los tipos de ICMP
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]     # Permitir desde cualquier IP (ajusta según tu necesidad)
  }
  # Reglas de egreso para permitir todo el tráfico saliente.
  egress {
    from_port   = 0                     # Puerto de salida (todos).
    to_port     = 0
    protocol    = "-1"                  # Permite todos los protocolos.
    cidr_blocks = ["0.0.0.0/0"]         # Permite tráfico hacia cualquier dirección IP.
  }
}

resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb-sg"
  description = "Grupo de seguridad para MongoDB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Permitir trafico desde el backend"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    #cidr_blocks = ["172.31.0.0/16"] # Cambiar según el CIDR de tu VPC
    cidr_blocks      = ["0.0.0.0/0"]
  }
    # Permitir ICMP (Ping)
  ingress {
    description      = "Permitir ICMP (Ping)"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]     # Permitir desde cualquier IP
  }

  # Reglas de ingreso para permitir acceso SSH.
  ingress {
    description      = "Permitir acceso SSH"
    from_port        = 22               # Puerto de entrada (SSH).
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    # Permite acceso desde cualquier dirección IP (debe ser restringido en entornos reales).
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

####################################################################################################
# CONFIGURACIÓN DE LAS ELASTIC NETWORK INTERFACES (ENI) CON IP PRIVADAS ESTÁTICAS
####################################################################################################
# CAMBIOS: Crear ENIs con direcciones IP estáticas
# A mis dos instancias les asignaré direcciones IP estáticas dentro de la misma subred privada (no son accesibles desde fuera de puerta enlace)
# servira para que se comunique entre ellas
resource "aws_network_interface" "web_server_eni" {
  subnet_id   = data.aws_subnet.default.id
  private_ips = ["172.31.16.10"] # IP estática para el servidor web
  security_groups = [aws_security_group.web_server_sg.id] # Asigna el grupo de seguridad del servidor web
  tags = {
    Name = "Web-Server-ENI"
  }
}
# resource "aws_eip" "web_server_eip" {
#   network_interface = aws_network_interface.web_server_eni.id
#   tags = {
#     Name = "Web-Server-EIP"
#   }
# }

resource "aws_network_interface" "mongodb_eni" {
  subnet_id   = data.aws_subnet.default.id
  private_ips = ["172.31.16.20"] # IP estática para MongoDB
  security_groups = [aws_security_group.mongodb_sg.id] # Asigna el grupo de seguridad de MongoDB
  tags = {
    Name = "MongoDB-ENI"
  }
}
# resource "aws_eip" "mongodb_eip" {
#   network_interface = aws_network_interface.mongodb_eni.id
#   tags = {
#     Name = "MongoDB-EIP"
#   }
# }
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

# Guardar la clave privada localmente en el directorio donde se ejecuta el apply
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
  ami                   = data.aws_ami.latest_ami.id
  instance_type         = var.instance_type
  key_name              = aws_key_pair.generated_key.key_name
  #vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  # Asociar la ENI con la instancia
  network_interface {
    network_interface_id = aws_network_interface.web_server_eni.id
    device_index         = 0
  }

  tags = {
    Name = var.instance_name
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = self.public_ip
  }

    # Ejecutar script Bash para sustituir el marcador y construir Angular
  provisioner "remote-exec" {
    inline = [

      # Iniciar el backend con PM2
      "sudo pm2 start /home/ubuntu/app.js",

      # Generar la URL dinámica con la IP pública
      #"BACKEND_URL=http://${self.public_ip}:3000",

      # Generar la URL dinámica con la IP pública
      "BACKEND_URL=http://${self.public_ip}",

      # Sustituir el marcador en app.component.ts
      "sudo sed -i 's|__BACKEND_URL__|'\"$BACKEND_URL\"'|g' /home/ubuntu/angular-app/src/app/app.component.ts",

      # Cambiar al directorio del proyecto Angular
      "cd /home/ubuntu/angular-app",

      "export NG_CLI_ANALYTICS=false",           # Desactiva analíticas
      "export CI=true",                          # Configura el entorno como CI/CD
      "echo n | ng analytics off --global",     # Desactiva preguntas interactivas
      "ng config -g cli.analytics false",       # Configura analíticas en Angular CLI
      "ng config -g cli.warnings.versionMismatch false", # Evita advertencias
      "sudo npm install",                       # Instala dependencias
      #"sudo ng build --configuration production --no-interactive", # Construye el proyecto sin interacción

      # Crear el directorio en Nginx si no existe
      "sudo mkdir -p /var/www/angular-app/dist",

      # Copiar los archivos generados al directorio que usa Nginx
      #"sudo cp -r dist/angular-app/* /var/www/angular-app/dist/",

      # Asegurarse de que los permisos sean correctos
      #"sudo chown -R www-data:www-data /var/www/angular-app/dist",
      #"sudo chmod -R 755 /var/www/angular-app/dist",

      # Reiniciar Nginx para servir los nuevos archivos
      "sudo systemctl restart nginx",
    ]
  }
}

# Configuración de la instancia MongoDB
resource "aws_instance" "mongodb" {
  ami                   = data.aws_ami.latest_ami.id
  instance_type         = var.instance_type
  key_name              = aws_key_pair.generated_key.key_name
  #vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  tags = {
    Name = "MongoDB-Instance"
  }

  # Asociar la ENI con la instancia
  network_interface {
    network_interface_id = aws_network_interface.mongodb_eni.id
    device_index         = 0
  }

    connection {
    type        = "ssh"
    user        = "ubuntu" # Usuario predeterminado de Ubuntu en AWS AMI
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = self.public_ip
  }


provisioner "remote-exec" {
  inline = [
    # Actualizar repositorios
    "sudo apt-get update",

    # Instalar MongoDB
    "sudo apt-get install -y mongodb",

    # Cambiar bind_ip a 0.0.0.0 en /etc/mongodb.conf
    "sudo sed -i 's/^bind_ip.*/bind_ip = 0.0.0.0/' /etc/mongodb.conf",

    # Reiniciar MongoDB para aplicar los cambios
    "sudo systemctl restart mongodb",

    # Habilitar MongoDB para que inicie automáticamente al arrancar el sistema
    "sudo systemctl enable mongodb"
  ]
}
}



################################################################################################################

# terraform apply -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token" 
# terraform destroy -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token"

# Get-ChildItem Env: | Where-Object { $_.Name -like "PKR_VAR_*" } --> ver credenciales actuales de AWS en la consola de powershell

# # ssh -i id_rsa ubuntu@34.228.13.36