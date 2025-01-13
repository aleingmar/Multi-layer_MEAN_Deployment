# DNS del Balanceador de Carga
output "load_balancer_dns" {
  description = "DNS público del balanceador de carga"
  value       = aws_lb.app_lb.dns_name
}
