output "oidc_provider_arn" {
  value = local.oidc_provider_arn
}

output "github_ecs_service_terraform_role_arn" {
  description = "Set as TERRAFORM_AWS_ROLE_ARN in microservice GitHub repos."
  value       = try(module.github_ecs_service_terraform_role[0].role_arn, null)
}

