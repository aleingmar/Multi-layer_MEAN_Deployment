output "web_server_security_group_id" {
  value       = aws_security_group.web_server_sg.id
  description = "ID del grupo de seguridad para los servidores web"
}

output "mongodb_security_group_id" {
  value       = aws_security_group.mongodb_sg.id
  description = "ID del grupo de seguridad para MongoDB"
}
output "private_key_pem" {
  value       = tls_private_key.ssh_key.private_key_pem
  description = "Clave privada generada"
  sensitive   = true
}

output "key_name" {
  value       = aws_key_pair.generated_key.key_name
  description = "Nombre de la clave SSH generada"
}
