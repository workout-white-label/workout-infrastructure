output "vpc_id" {
  description = "Platform VPC ID."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "Platform VPC CIDR."
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "Private subnets for ECS services."
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnets (NAT)."
  value       = module.vpc.public_subnet_ids
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN for microservices."
  value       = module.ecs_cluster.cluster_arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs_cluster.cluster_name
}

output "ecs_tasks_security_group_id" {
  description = "Security group to attach to ECS task ENIs."
  value       = aws_security_group.ecs_tasks.id
}

output "ecs_log_group_name" {
  description = "Default CloudWatch log group for ECS services."
  value       = module.ecs_cluster.log_group_name
}

output "internal_alb_arn" {
  description = "Internal ALB ARN."
  value       = module.internal_alb.alb_arn
}

output "internal_alb_dns_name" {
  description = "Internal ALB DNS name."
  value       = module.internal_alb.alb_dns_name
}

output "internal_alb_listener_arn" {
  description = "Internal ALB HTTP listener ARN (attach per-service rules here)."
  value       = module.internal_alb.listener_arn
}

output "internal_alb_security_group_id" {
  description = "Security group ID of the internal ALB."
  value       = aws_security_group.alb.id
}

output "vpc_link_security_group_id" {
  description = "Security group ID for API Gateway VPC Link ENIs."
  value       = aws_security_group.vpc_link.id
}

output "api_gateway_endpoint" {
  description = "Public API Gateway invoke URL."
  value       = module.api_gateway.api_endpoint
}

output "api_gateway_id" {
  description = "API Gateway HTTP API ID."
  value       = module.api_gateway.api_id
}

output "vpc_link_id" {
  description = "API Gateway VPC Link v2 ID."
  value       = module.api_gateway.vpc_link_id
}
