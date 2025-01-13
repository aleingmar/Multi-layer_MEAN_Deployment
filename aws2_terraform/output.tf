##################################################################  Outputs del módulo Compute
output "web_server_ssh_commands" {
  description = "Comandos SSH para conectarse a los nodos web"
  value       = module.compute.web_server_ssh_commands
}

output "web_server_public_ips" {
  description = "IP públicas de los nodos web"
  value       = module.compute.web_server_public_ips
}

output "web_server_private_ips" {
  description = "IP privadas de los nodos web"
  value       = module.compute.web_server_private_ips
}

output "mongodb_nat_gateway_public_ip" {
  description = "IP pública del NAT Gateway asociado a la instancia MongoDB"
  value       = module.compute.mongodb_nat_gateway_public_ip
}

################################################################# Outputs del módulo Load Balancer
output "load_balancer_dns" {
  description = "DNS público del balanceador de carga"
  value       = module.load_balancer.load_balancer_dns
}
