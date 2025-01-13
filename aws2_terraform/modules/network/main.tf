resource "aws_vpc" "custom_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.public_subnet_1_cidr # (IPs: 172.31.16.0 - 172.31.16.127)
  availability_zone = var.availability_zone_1
  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.public_subnet_2_cidr #(IPs: 172.31.16.128 - 172.31.16.255)
  availability_zone = var.availability_zone_2
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
# CONFIGURACIÓN DE :
# LAS ELASTIC NETWORK INTERFACES (ENI) CON IP PRIVADAS ESTÁTICAS 
# LAS Elastic IPs (EIP) asignar ip dinamicas a las instancias
####################################################################################################
# CAMBIOS: Crear ENIs con direcciones IP estáticas
# A mis dos instancias les asignaré direcciones IP estáticas dentro de la misma subred privada (no son accesibles desde fuera de puerta enlace)
# servira para que se comunique entre ellas

# ENIs para los servidores web
resource "aws_network_interface" "web_server_eni" {
  count       = var.web_server_count
  subnet_id   = var.public_subnet_id
  private_ips = ["172.31.16.${count.index + 10}"] # Ejemplo de IPs estáticas
  security_groups = [var.web_server_sg_id]
}

# EIPs para los servidores web
resource "aws_eip" "web_server_eip" {
  count             = var.web_server_count
  network_interface = aws_network_interface.web_server_eni[count.index].id
}


# ENI para MongoDB
resource "aws_network_interface" "mongodb_eni" {
  subnet_id       = var.mongodb_subnet_id
  private_ips     = ["172.31.16.20"]
  security_groups = [var.mongodb_sg_id]
}

# EIP para MongoDB
resource "aws_eip" "mongodb_eip" {
  network_interface = aws_network_interface.mongodb_eni.id
}

