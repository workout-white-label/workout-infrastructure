output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.main.name
}

output "service_arn" {
  description = "ECS service ARN."
  value       = aws_ecs_service.main.id
}

output "task_definition_arn" {
  description = "Task definition ARN."
  value       = aws_ecs_task_definition.main.arn
}

output "task_definition_family" {
  description = "Task definition family."
  value       = aws_ecs_task_definition.main.family
}

output "container_name" {
  description = "Container name in the task definition."
  value       = var.service_name
}

output "target_group_arn" {
  description = "ALB target group ARN."
  value       = aws_lb_target_group.main.arn
}

output "listener_rule_arn" {
  description = "ALB listener rule ARN."
  value       = aws_lb_listener_rule.main.arn
}

output "task_execution_role_arn" {
  description = "IAM role ARN for ECS task execution."
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "IAM role ARN for the running task."
  value       = aws_iam_role.task.arn
}
