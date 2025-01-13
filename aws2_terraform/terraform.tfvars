# Network
vpc_cidr             = "172.31.16.0/24"
vpc_name             = "CustomVPC"
public_subnet_1_cidr = "172.31.16.0/25"
public_subnet_2_cidr = "172.31.16.128/25"
availability_zone_1  = "us-east-1a"
availability_zone_2  = "us-east-1b"

# Security
web_sg_name          = "WebServerSG"
mongodb_sg_name      = "MongoDBSG"

# Compute
ami_id               = "ami-12345678"
instance_type        = "t2.micro"
web_server_count     = 2
web_server_name      = "WebServer"
mongodb_name         = "MongoDB"

# Load Balancer
lb_name              = "AppLoadBalancer"
target_group_name    = "AppTargetGroup"