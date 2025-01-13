# VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.vpc_name
  }
}

# Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.subnet_1_cidr
  availability_zone = var.subnet_1_az
  tags = {
    Name = var.subnet_1_name
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.subnet_2_cidr
  availability_zone = var.subnet_2_az
  tags = {
    Name = var.subnet_2_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = var.igw_name
  }
}

# Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
  }

  tags = {
    Name = var.route_table_name
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
