output "cluster_id" {
  description = "ECS cluster ID."
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ECS cluster ARN."
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "log_group_name" {
  description = "Default CloudWatch log group for ECS services."
  value       = aws_cloudwatch_log_group.ecs.name
}

output "log_group_arn" {
  description = "ARN of the default CloudWatch log group for ECS services."
  value       = aws_cloudwatch_log_group.ecs.arn
}
