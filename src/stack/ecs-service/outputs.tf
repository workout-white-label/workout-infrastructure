output "service_name" {
  value = module.ecs_service.service_name
}

output "container_name" {
  value = module.ecs_service.container_name
}

output "ecs_cluster_name" {
  value = data.terraform_remote_state.platform.outputs.ecs_cluster_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "github_deploy_role_arn" {
  description = "Set as AWS_ROLE_ARN in the microservice GitHub repository."
  value       = module.github_deploy_role.role_arn
}

output "task_definition_family" {
  value = module.ecs_service.task_definition_family
}

output "credentials_secret_path" {
  description = "Database credentials path when create_database = true."
  value       = try(module.database[0].credentials_secret_path, null)
}
