output "load_balancer_dns" {
  value       = aws_lb.app_lb.dns_name
  description = "Nombre DNS del Load Balancer"
}

output "target_group_arn" {
  value       = aws_lb_target_group.app_target_group.arn
  description = "ARN del Target Group del Load Balancer"
}