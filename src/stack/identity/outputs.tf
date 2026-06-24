output "user_pool_id" {
  description = "Cognito user pool ID."
  value       = module.cognito.user_pool_id
}

output "user_pool_arn" {
  description = "Cognito user pool ARN."
  value       = module.cognito.user_pool_arn
}

output "client_ids" {
  description = "Map of client name to Cognito app client ID (e.g. client_ids[\"app\"], client_ids[\"web\"])."
  value       = module.cognito.client_ids
}

output "client_secrets" {
  description = "Map of client name to client secret (only where generate_secret = true)."
  value       = module.cognito.client_secrets
  sensitive   = true
}

output "cognito_domain" {
  description = "Cognito hosted UI base URL."
  value       = module.cognito.cognito_domain
}
output "cognito_domain_prefix" {
  description = "Cognito hosted UI domain prefix."
  value       = module.cognito.cognito_domain_prefix
}

output "supported_identity_providers" {
  description = "Federated and native IdPs enabled on the app client."
  value       = module.cognito.supported_identity_providers
}

