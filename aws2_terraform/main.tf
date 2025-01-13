# Proveedor AWS
provider "aws" {
  region = "us-east-1"
}


module "network" {
  source                = "./modules/network"
  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  availability_zone_1   = var.availability_zone_1
  availability_zone_2   = var.availability_zone_2
}

module "security" {
  source       = "./modules/security"
  vpc_id       = module.network.vpc_id
  web_sg_name  = var.web_sg_name
  mongodb_sg_name = var.mongodb_sg_name
}

module "compute" {
  source                = "./modules/compute"
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  key_name              = aws_key_pair.generated_key.key_name
  private_key           = tls_private_key.ssh_key.private_key_pem
  web_server_count      = var.web_server_count
  web_server_name       = var.web_server_name
  web_server_eni_ids    = module.network.public_subnet_1_id
  web_server_public_ips = module.network.public_subnet_2_id
  mongodb_name          = var.mongodb_name
  mongodb_eni_id        = aws_network_interface.mongodb_eni.id
  mongodb_public_ip     = aws_eip.mongodb_eip.public_ip
}

module "load_balancer" {
  source               = "./modules/load_balancer"
  lb_name              = var.lb_name
  lb_security_group_id = module.security.web_server_sg_id
  subnet_ids           = [module.network.public_subnet_1_id, module.network.public_subnet_2_id]
  vpc_id               = module.network.vpc_id
  target_group_name    = var.target_group_name
  web_server_ids       = module.compute.web_server_ids
}
