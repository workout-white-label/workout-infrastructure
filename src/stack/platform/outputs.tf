output "vpc_id" {
  description = "Platform VPC ID."
  value       = module.network.vpc_id
}

output "vpc_cidr_block" {
  description = "Platform VPC CIDR."
  value       = module.network.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "Private subnets for ECS services."
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnets (NAT)."
  value       = module.network.public_subnet_ids
}

output "private_route_table_ids" {
  description = "Private route table IDs (for VPC peering from ecs-service stack)."
  value       = module.network.private_route_table_ids
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN."
  value       = module.compute.ecs_cluster_arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.compute.ecs_cluster_name
}

output "ecs_log_group_name" {
  description = "CloudWatch log group for ECS services."
  value       = module.compute.ecs_log_group_name
}

output "ecs_tasks_security_group_id" {
  description = "Security group for ECS task ENIs."
  value       = module.edge.ecs_tasks_security_group_id
}

output "internal_alb_arn" {
  value = module.edge.alb_arn
}

output "internal_alb_dns_name" {
  value = module.edge.alb_dns_name
}

output "internal_alb_listener_arn" {
  description = "Attach per-service listener rules from ecs-service stack."
  value       = module.edge.listener_arn
}

output "internal_alb_security_group_id" {
  value = module.edge.alb_security_group_id
}

output "vpc_link_security_group_id" {
  value = module.edge.vpc_link_security_group_id
}

output "api_gateway_endpoint" {
  value = module.edge.api_gateway_endpoint
}

output "api_gateway_id" {
  value = module.edge.api_gateway_id
}

output "vpc_link_id" {
  value = module.edge.vpc_link_id
}

output "github_oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN (used by ecs-service stack)."
  value       = module.ci.oidc_provider_arn
}

output "github_ecs_service_terraform_role_arn" {
  description = "IAM role for microservice repos to apply ecs-service Terraform in CI."
  value       = module.ci.github_ecs_service_terraform_role_arn
}

output "ssm_bastion_instance_id" {
  description = "EC2 instance ID for SSM port forwarding to private RDS (null if enable_ssm_bastion = false)."
  value       = try(module.bastion[0].instance_id, null)
}
