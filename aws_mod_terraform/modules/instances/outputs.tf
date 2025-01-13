output "web_server_ids" {
  value       = aws_instance.web_server[*].id
  description = "IDs de las instancias EC2 de los servidores web"
}

output "web_server_private_ips" {
  value       = aws_network_interface.web_server_eni[*].private_ips
  description = "IPs privadas de las ENIs de los servidores web"
}

output "web_server_public_ips" {
  value       = aws_eip.web_server_eip[*].public_ip
  description = "IPs públicas de los servidores web"
}

output "mongodb_id" {
  value       = aws_instance.mongodb.id
  description = "ID de la instancia EC2 de MongoDB"
}

output "mongodb_private_ip" {
  value       = aws_network_interface.mongodb_eni.private_ips[0]
  description = "IP privada de la ENI de MongoDB"
}

output "mongodb_public_ip" {
  value       = aws_eip.mongodb_eip.public_ip
  description = "IP pública de MongoDB"
}