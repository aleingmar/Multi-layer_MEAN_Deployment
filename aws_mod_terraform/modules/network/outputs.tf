output "vpc_id" {
  value       = aws_vpc.custom_vpc.id
  description = "ID de la VPC creada"
}

output "subnet_1_id" {
  value       = aws_subnet.public_subnet_1.id
  description = "ID de la primera subnet pública"
}

output "subnet_2_id" {
  value       = aws_subnet.public_subnet_2.id
  description = "ID de la segunda subnet pública"
}

output "igw_id" {
  value       = aws_internet_gateway.custom_igw.id
  description = "ID del Internet Gateway"
}

output "route_table_id" {
  value       = aws_route_table.public_route_table.id
  description = "ID de la Route Table"
}
