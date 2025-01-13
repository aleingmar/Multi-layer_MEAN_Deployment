# Proveedor AWS
provider "aws" {
  region = "us-east-1"
}

# Configuración de Load Balancer
module "load_balancer" {
  source           = "./modules/load_balancer"
  lb_name          = "app-load-balancer"
  security_groups  = [aws_security_group.web_server_sg.id]
  subnets          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  vpc_id           = aws_vpc.custom_vpc.id
  instance_count   = length(aws_instance.web_server)
  target_ids       = aws_instance.web_server[*].id
}

# Configuración de Seguridad
module "security" {
  source              = "./modules/security"
  vpc_id              = aws_vpc.custom_vpc.id
  web_server_name     = "web-server"
  ingress_cidr_blocks = ["0.0.0.0/0"] # Ajusta según requisitos de seguridad
  key_name            = "unir"       # Nombre real del par de claves configurado
}

# Configuración de Red
module "network" {
  source              = "./modules/network"
  vpc_cidr_block      = "172.31.16.0/24"
  vpc_name            = "CustomVPC"
  subnet_1_cidr       = "172.31.16.0/25"
  subnet_1_az         = "us-east-1a"
  subnet_1_name       = "PublicSubnet1"
  subnet_2_cidr       = "172.31.16.128/25"
  subnet_2_az         = "us-east-1b"
  subnet_2_name       = "PublicSubnet2"
  igw_name            = "CustomIGW"
  route_table_name    = "PublicRouteTable"
}

# Configuración de Instancias EC2
module "instances" {
  source                        = "./modules/instances"
  instance_type                 = "t2.micro"
  key_name                      = "unir" # Par de claves real utilizado
  ssh_private_key               = file("~/.ssh/unir.pem") # Ruta real de la clave privada
  web_server_count              = 2
  web_server_ami                = data.aws_ami.latest_ami.id # Utiliza la última AMI creada
  web_server_subnet_id          = aws_subnet.public_subnet_1.id
  web_server_private_ip_base    = "172.31.16"
  web_server_security_group_id  = aws_security_group.web_server_sg.id
  web_server_instance_name      = "Instance_stack_MEAN"
  mongodb_ami                   = data.aws_ami.latest_ami.id # Utiliza la misma AMI para MongoDB
  mongodb_subnet_id             = aws_subnet.public_subnet_2.id
  mongodb_private_ip            = "172.31.16.20"
  mongodb_security_group_id     = aws_security_group.mongodb_sg.id
}

# Configuración de Imagen con Packer
module "image" {
  source               = "./modules/image"
  aws_access_key       = var.aws_access_key
  aws_secret_key       = var.aws_secret_key
  aws_session_token    = var.aws_session_token
  packer_var_file      = "../aws_packer/variables.pkrvars.hcl"
  packer_template_file = "../aws_packer/main.pkr.hcl"
  ami_name             = "imagen_stack_MEAN" # Nombre base de la AMI configurada
}