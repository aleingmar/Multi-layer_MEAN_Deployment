#################    APUNTES   ##########################3
#  module.network.vpc_id --> Se accede asi a esto pk viene definido en el output del modulo network
# Los outputs se usan para usar valores que se generan por un modulo --> por eso suelen ser id's
###########################################3

# Proveedor AWS
provider "aws" {
  region = "us-east-1"
}

# Configuración de Red: Define y gestiona la red (VPC, subnets, etc.)
module "network" {
  source              = "./modules/network"
  vpc_cidr_block      = "172.31.16.0/24" # Local al módulo de red: Solo se utiliza dentro del módulo `network`.
  vpc_name            = "CustomVPC"     # Local al módulo de red: Solo se utiliza dentro del módulo `network`.
  subnet_1_cidr       = "172.31.16.0/25" # Local al módulo de red: Solo se utiliza dentro del módulo `network`.
  subnet_1_az         = "us-east-1a"    # Local al módulo de red: Solo se utiliza dentro del módulo `network`.
  subnet_1_name       = "PublicSubnet1" # Local al módulo de red: Solo se utiliza dentro del módulo `network`.
  subnet_2_cidr       = "172.31.16.128/25" # Local al módulo de red: Solo se utiliza dentro del módulo `network`.
  subnet_2_az         = "us-east-1b"    # Local al módulo de red: Solo se utiliza dentro del módulo `network`.
  subnet_2_name       = "PublicSubnet2" # Local al módulo de red: Solo se utiliza dentro del módulo `network`.
  igw_name            = "CustomIGW"     # Local al módulo de red: Solo se utiliza dentro del módulo `network`.
  route_table_name    = "PublicRouteTable" # Local al módulo de red: Solo se utiliza dentro del módulo `network`.
}

# Configuración de Seguridad: Define grupos de seguridad y claves SSH.
module "security" {
  source              = "./modules/security"
  vpc_id              = module.network.vpc_id # Global: Se utiliza en los módulos `network`, `security` e `instances`.
  web_server_name     = "Instance_stack_MEAN"         # Local al módulo de seguridad: Solo se utiliza dentro del módulo `security`.
  ingress_cidr_blocks = ["0.0.0.0/0"]        # Local al módulo de seguridad: Solo se utiliza dentro del módulo `security`.
  key_name            = var.key_name              # Global: Se utiliza en los módulos `security` e `instances`.
}

# Configuración de Instancias EC2: Define las instancias y sus configuraciones.
module "instances" {
  source                        = "./modules/instances"
  instance_type                 = "t2.micro" # Local al módulo de instancias: Solo se utiliza dentro del módulo `instances`.
  key_name                      = var.key_name # Global: Se utiliza en los módulos `security` e `instances`.
  ssh_private_key               = module.security.ssh_private_key # Global: Se utiliza en los módulos `security` e `instances`.
  web_server_count              = 2 # Local al módulo de instancias: Solo se utiliza dentro del módulo `instances`.
  web_server_ami                = module.image.latest_ami_id # Global: Se utiliza en los módulos `image` e `instances`.
  web_server_subnet_id          = module.network.subnet_1_id # Global: Se utiliza en los módulos `network` e `instances`.
  web_server_private_ip_base    = "172.31.16" # Local al módulo de instancias: Solo se utiliza dentro del módulo `instances`.
  web_server_security_group_id  = module.security.web_server_security_group_id # Global: Se utiliza en los módulos `security` e `instances`.
  web_server_instance_name      = "Instance_stack_MEAN" # Local al módulo de instancias: Solo se utiliza dentro del módulo `instances`.
  mongodb_ami                   = module.image.latest_ami_id # Global: Se utiliza en los módulos `image` e `instances`.
  mongodb_subnet_id             = module.network.subnet_1_id # Global: Se utiliza en los módulos `network` e `instances`.
  mongodb_private_ip            = "172.31.16.20" # Local al módulo de instancias: Solo se utiliza dentro del módulo `instances`.
  mongodb_security_group_id     = module.security.mongodb_security_group_id # Global: Se utiliza en los módulos `security` e `instances`.
}

# Configuración del Load Balancer: Define y gestiona el balanceador de carga.
module "load_balancer" {
  source           = "./modules/load_balancer"
  lb_name          = "app-load-balancer" # Local al módulo de load balancer: Solo se utiliza dentro del módulo `load_balancer`.
  security_groups  = [module.security.web_server_security_group_id] # Global: Se utiliza en los módulos `security` y `load_balancer`.
  subnets          = [module.network.subnet_1_id, module.network.subnet_2_id] # Global: Se utiliza en los módulos `network` y `load_balancer`.
  vpc_id           = module.network.vpc_id # Global: Se utiliza en los módulos `network`, `security`, `instances` y `load_balancer`.
  instance_target_count   = 2 # Local al módulo de load balancer: Calculado con datos de `instances`.
  target_ids       = module.instances.web_server_ids # Global: Se utiliza en los módulos `instances` y `load_balancer`.
}

# Configuración de Imagen (Packer): Define la AMI personalizada.
module "image" {
  source               = "./modules/image"
  aws_access_key       = var.aws_access_key # Global: Se utiliza en el módulo `image`.
  aws_secret_key       = var.aws_secret_key # Global: Se utiliza en el módulo `image`.
  aws_session_token    = var.aws_session_token # Global: Se utiliza en el módulo `image`.
  packer_var_file      = "../aws_packer/variables.pkrvars.hcl" # Local al módulo de imagen: Solo se utiliza dentro del módulo `image`.
  packer_template_file = "../aws_packer/main.pkr.hcl" # Local al módulo de imagen: Solo se utiliza dentro del módulo `image`.
  ami_name             = "imagen_stack_MEAN" # Local al módulo de imagen: Solo se utiliza dentro del módulo `image`.
}


#########################################################3
# terraform apply -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token" 
# terraform destroy -var "aws_access_key=$env:PKR_VAR_aws_access_key" ` -var "aws_secret_key=$env:PKR_VAR_aws_secret_key" ` -var "aws_session_token=$env:PKR_VAR_aws_session_token"

# Get-ChildItem Env: | Where-Object { $_.Name -like "PKR_VAR_*" } --> ver credenciales actuales de AWS en la consola de powershell

# # ssh -i id_rsa ubuntu@98.84.118.14

# sudo apt install mongodb-clients && mongo --host 172.31.16.20 --port 27017

# for i in {1..10}; do curl -I -v http://app-load-balancer-1360292704.us-east-1.elb.amazonaws.com/ 2>&1 | grep 'Connected to'; done