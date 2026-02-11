output "frontend_service_name" {
  description = "Name of the ECS frontend service"
  value       = aws_ecs_service.frontend_service.name
}

output "backend_service_name" {
  description = "Name of the ECS backend service"
  value       = aws_ecs_service.backend_service.name
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.app_cluster.name
}
