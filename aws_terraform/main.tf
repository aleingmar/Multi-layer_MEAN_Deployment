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
# data "aws_vpc" "default" {
#   default = true # Recupera la VPC predeterminada asociada a la cuenta AWS.
# }
# # me fijo en las subreedes que tiene la vpc por defecto
# data "aws_subnet" "public_subnet_1" {
#   filter {
#     name   = "availability-zone"
#     values = ["us-east-1a"] # Primera zona de disponibilidad
#   }
# }

# data "aws_subnet" "public_subnet_2" {
#   filter {
#     name   = "availability-zone"
#     values = ["us-east-1b"] # Segunda zona de disponibilidad
#   }
# }

resource "aws_vpc" "custom_vpc" {
  cidr_block = "172.31.16.0/24"
  tags = {
    Name = "CustomVPC"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "172.31.16.0/25" # (IPs: 172.31.16.0 - 172.31.16.127)
  availability_zone = "us-east-1a"
  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "172.31.16.128/25" #(IPs: 172.31.16.128 - 172.31.16.255)
  availability_zone = "us-east-1b"
  tags = {
    Name = "PublicSubnet2"
  }
}

resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "CustomIGW"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
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
  #vpc_id      = aws_vpc.custom_vpc.id  # Asocia este grupo de seguridad a la VPC predeterminada.
  vpc_id      = length(aws_vpc.custom_vpc) > 0 ? aws_vpc.custom_vpc.id : null
  
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
  vpc_id      = aws_vpc.custom_vpc.id

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
  count       = 2
  subnet_id   = aws_subnet.public_subnet_1.id
  private_ips = ["172.31.16.${count.index + 10}"] # IPs dinámicas: 172.31.16.10, 172.31.16.11
  security_groups = [aws_security_group.web_server_sg.id]
}
resource "aws_eip" "web_server_eip" {
  count             = 2
  network_interface = aws_network_interface.web_server_eni[count.index].id
  tags = {
    Name = "Web-Server-EIP-${count.index + 1}"
  }
}

resource "aws_network_interface" "mongodb_eni" {
  subnet_id = aws_subnet.public_subnet_1.id
  private_ips = ["172.31.16.20"] # IP estática para MongoDB
  security_groups = [aws_security_group.mongodb_sg.id] # Asigna el grupo de seguridad de MongoDB
  tags = {
    Name = "MongoDB-ENI"
  }
}
resource "aws_eip" "mongodb_eip" {
  network_interface = aws_network_interface.mongodb_eni.id
  tags = {
    Name = "MongoDB-EIP"
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
  count                 = 2
  #associate_public_ip_address = true
  #vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  # Asociar la ENI con la instancia
  network_interface {
    network_interface_id = aws_network_interface.web_server_eni[count.index].id
    device_index         = 0
  }

  tags = {
  Name = "${var.instance_name}-${count.index + 1}"
}
  

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = aws_eip.web_server_eip[count.index].public_ip # Usa la IP pública para conectar
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

      # Sustituir __NUM_INST__ con el número de instancia
      #"sudo sed -i 's|__NUM_INST__|'\"$((count.index + 1))\"'|g' /home/ubuntu/angular-app/src/app/app.component.ts",
      "sudo sed -i 's|__NUM_INST__|'\"${count.index + 1}\"'|g' /home/ubuntu/angular-app/src/app/app.component.ts",


      # Cambiar al directorio del proyecto Angular
      "cd /home/ubuntu/angular-app",

      # "export NG_CLI_ANALYTICS=false",           # Desactiva analíticas
      # "export CI=true",                          # Configura el entorno como CI/CD
      # "echo n | ng analytics off --global",     # Desactiva preguntas interactivas
      # "ng config -g cli.analytics false",       # Configura analíticas en Angular CLI
      # "ng config -g cli.warnings.versionMismatch false", # Evita advertencias
      "sudo npm install",                       # Instala dependencias
      "(sleep 5; echo 'n'; sleep 10; echo 'N') | sudo ng build --configuration=production", # Construye el proyecto sin interacción

      # Crear el directorio en Nginx si no existe
      "sudo mkdir -p /var/www/angular-app/dist",

      # Copiar los archivos generados al directorio que usa Nginx
      "sudo cp -r dist/angular-app/* /var/www/angular-app/dist/",

      # Asegurarse de que los permisos sean correctos
      "sudo chown -R www-data:www-data /var/www/angular-app/dist",
      "sudo chmod -R 755 /var/www/angular-app/dist",

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
  #associate_public_ip_address = true
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
    host        = aws_eip.mongodb_eip.public_ip # Usa la IP pública para conectar
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
################################ BALANCEADOR
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_server_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "App-Load-Balancer"
  }
}

# resource "aws_lb_target_group" "app_target_group" {
#   name     = "app-target-group"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.custom_vpc.id

#   tags = {
#     Name = "App-Target-Group"
#   }
# }
resource "aws_lb_target_group" "app_target_group" {
  name                          = "app-target-group"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = aws_vpc.custom_vpc.id
  load_balancing_algorithm_type = "round_robin"

  stickiness {
    type            = "lb_cookie"
    enabled         = false
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "App-Target-Group"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "web_server_attachment" {
  count             = length(aws_instance.web_server)
  target_group_arn  = aws_lb_target_group.app_target_group.arn
  target_id         = aws_instance.web_server[count.index].id
  port              = 80
}



################################################################################################################

# terraform apply -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token" 
# terraform destroy -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token"

# Get-ChildItem Env: | Where-Object { $_.Name -like "PKR_VAR_*" } --> ver credenciales actuales de AWS en la consola de powershell

# # ssh -i id_rsa ubuntu@98.84.118.14

# sudo apt install mongodb-clients && mongo --host 172.31.16.20 --port 27017

# for i in {1..10}; do curl -I -v http://app-load-balancer-1360292704.us-east-1.elb.amazonaws.com/ 2>&1 | grep 'Connected to'; done