# Comandos SSH para conectarse a los nodos web
output "web_server_ssh_commands" {
  description = "Comandos SSH para conectarse a los nodos web"
  value       = [for eip in aws_eip.web_server_eip : "ssh -i id_rsa ubuntu@${eip.public_ip}"]
}

# IP públicas de los nodos web
output "web_server_public_ips" {
  description = "IP públicas de los nodos web"
  value       = [for eip in aws_eip.web_server_eip : eip.public_ip]
}

# IP privadas de los nodos web
output "web_server_private_ips" {
  description = "IP privadas de los nodos web"
  value       = [for eni in aws_network_interface.web_server_eni : eni.private_ip]
}

# IP pública de MongoDB
output "mongodb_nat_gateway_public_ip" {
  description = "IP pública del NAT Gateway asociado a la instancia MongoDB"
  value       = aws_eip.mongodb_eip.public_ip
}
