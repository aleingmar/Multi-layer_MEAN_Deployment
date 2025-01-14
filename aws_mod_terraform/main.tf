#################    APUNTES   ##########################3
#  module.network.vpc_id --> Se accede asi a esto pk viene definido en el output del modulo network
# Los outputs se usan para usar valores que se generan por un modulo --> por eso suelen ser id's
###########################################3

# Proveedor AWS
provider "aws" {
  region = "us-east-1"
}

# Configuración de Red: Define y gestiona la red (VPC, subnets, etc.)
# Configuración de Red
module "network" {
  source              = "./modules/network"
  vpc_cidr_block      = "172.31.16.0/24" # módulos: network
  vpc_name            = "CustomVPC"     # módulos: network
  subnet_1_cidr       = "172.31.16.0/25" # módulos: network
  subnet_1_az         = "us-east-1a"    # módulos: network
  subnet_1_name       = "PublicSubnet1" # módulos: network
  subnet_2_cidr       = "172.31.16.128/25" # módulos: network
  subnet_2_az         = "us-east-1b"    # módulos: network
  subnet_2_name       = "PublicSubnet2" # módulos: network
  igw_name            = "CustomIGW"     # módulos: network
  route_table_name    = "PublicRouteTable" # módulos: network
}

# Configuración de Seguridad
# Configuración de Seguridad: Define grupos de seguridad y claves SSH.
module "security" {
  source              = "./modules/security"
  vpc_id              = module.network.vpc_id # módulos: network, security, instances
  web_server_name     = "Instance_stack_MEAN" # módulos: security
  ingress_cidr_blocks = ["0.0.0.0/0"]        # módulos: security
  key_name            = var.key_name          # módulos: security, instances
}

# Configuración de Instancias EC2
# Configuración de Instancias EC2: Define las instancias y sus configuraciones.
module "instances" {
  source                        = "./modules/instances"
  instance_type                 = "t2.micro" # módulos: instances
  key_name                      = var.key_name # módulos: security, instances
  ssh_private_key               = module.security.ssh_private_key # módulos: security, instances
  web_server_count              = 2 # módulos: instances
  web_server_ami                = module.image.latest_ami_id # módulos: image, instances
  web_server_subnet_id          = module.network.subnet_1_id # módulos: network, instances
  web_server_private_ip_base    = "172.31.16" # módulos: instances
  web_server_security_group_id  = module.security.web_server_security_group_id # módulos: security, instances
  web_server_instance_name      = "Instance_stack_MEAN" # módulos: instances
  mongodb_ami                   = module.image.latest_ami_id # módulos: image, instances
  mongodb_subnet_id             = module.network.subnet_1_id # módulos: network, instances
  mongodb_private_ip            = "172.31.16.20" # módulos: instances
  mongodb_security_group_id     = module.security.mongodb_security_group_id # módulos: security, instances
}

# Configuración del Load Balancer
# Configuración del Load Balancer: Define y gestiona el balanceador de carga.
module "load_balancer" {
  source           = "./modules/load_balancer"
  lb_name          = "app-load-balancer" # módulos: load_balancer
  security_groups  = [module.security.web_server_security_group_id] # módulos: security, load_balancer
  subnets          = [module.network.subnet_1_id, module.network.subnet_2_id] # módulos: network, load_balancer
  vpc_id           = module.network.vpc_id # módulos: network, security, instances, load_balancer
  instance_target_count   = 2 # módulos: load_balancer
  target_ids       = module.instances.web_server_ids # módulos: instances, load_balancer
}

# Configuración de Imagen (Packer)
# Configuración de Imagen (Packer): Define y recupera la AMI personalizada.
module "image" {
  source               = "./modules/image"
  aws_access_key       = var.aws_access_key # módulos: image
  aws_secret_key       = var.aws_secret_key # módulos: image
  aws_session_token    = var.aws_session_token # módulos: image
  packer_var_file      = "../aws_packer/variables.pkrvars.hcl" # módulos: image
  packer_template_file = "../aws_packer/main.pkr.hcl" # módulos: image
  ami_name             = "imagen_stack_MEAN" # módulos: image
}


#########################################################3
# terraform apply -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token" 
# terraform destroy -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token"

# Get-ChildItem Env: | Where-Object { $_.Name -like "PKR_VAR_*" } --> ver credenciales actuales de AWS en la consola de powershell

# # ssh -i id_rsa ubuntu@98.84.118.14

# sudo apt install mongodb-clients && mongo --host 172.31.16.20 --port 27017

# for i in {1..10}; do curl -I -v http://app-load-balancer-1360292704.us-east-1.elb.amazonaws.com/ 2>&1 | grep 'Connected to'; done