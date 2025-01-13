# Proveedor AWS
provider "aws" {
  region = "var.aws_region"
}

# Configuración de la Red
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

# Configuración de Seguridad
module "security" {
  source              = "./modules/security"
  vpc_id              = module.network.vpc_id
  web_server_name     = "web-server"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  key_name            = "unir"
}

# Configuración de Instancias EC2

module "instances" {
  source                        = "./modules/instances"
  instance_type                 = "t2.micro"
  key_name                      = "unir"
  ssh_private_key               = module.security.private_key_pem
  web_server_count              = 2
  web_server_ami                = module.image.latest_ami_id
  web_server_subnet_id          = module.network.subnet_1_id
  web_server_private_ip_base    = "172.31.16"
  web_server_security_group_id  = module.security.web_server_security_group_id
  web_server_instance_name      = "Instance_stack_MEAN"
  mongodb_ami                   = module.image.latest_ami_id
  mongodb_subnet_id             = module.network.subnet_2_id
  mongodb_private_ip            = "172.31.16.20"
  mongodb_security_group_id     = module.security.mongodb_security_group_id
}

# Configuración de Load Balancer
module "load_balancer" {
  source           = "./modules/load_balancer"
  lb_name          = "app-load-balancer"
  security_groups  = [module.security.web_server_security_group_id]
  subnets          = [module.network.subnet_1_id, module.network.subnet_2_id]
  vpc_id           = module.network.vpc_id
  instance_count   = module.instances.web_server_count
  target_ids       = module.instances.web_server_ids
}

# Configuración de la Imagen (Packer)
module "image" {
  source               = "./modules/image"
  aws_access_key       = var.aws_access_key
  aws_secret_key       = var.aws_secret_key
  aws_session_token    = var.aws_session_token
  packer_var_file      = "../aws_packer/variables.pkrvars.hcl"
  packer_template_file = "../aws_packer/main.pkr.hcl"
  ami_name             = "imagen_stack_MEAN"
}

#########################################################3
# terraform apply -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token" 
# terraform destroy -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token"

# Get-ChildItem Env: | Where-Object { $_.Name -like "PKR_VAR_*" } --> ver credenciales actuales de AWS en la consola de powershell

# # ssh -i id_rsa ubuntu@98.84.118.14

# sudo apt install mongodb-clients && mongo --host 172.31.16.20 --port 27017

# for i in {1..10}; do curl -I -v http://app-load-balancer-1360292704.us-east-1.elb.amazonaws.com/ 2>&1 | grep 'Connected to'; done