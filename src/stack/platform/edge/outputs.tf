output "ecs_tasks_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}

output "alb_arn" {
  value = module.internal_alb.alb_arn
}

output "alb_dns_name" {
  value = module.internal_alb.alb_dns_name
}

output "listener_arn" {
  value = module.internal_alb.listener_arn
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "vpc_link_security_group_id" {
  value = aws_security_group.vpc_link.id
}

output "api_gateway_endpoint" {
  value = module.api_gateway.api_endpoint
}

output "api_gateway_id" {
  value = module.api_gateway.api_id
}

output "vpc_link_id" {
  value = module.api_gateway.vpc_link_id
}
