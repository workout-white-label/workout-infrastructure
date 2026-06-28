output "user_pool_id" {
  description = "ID of the Cognito user pool."
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito user pool."
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito user pool."
  value       = aws_cognito_user_pool.main.endpoint
}

output "client_ids" {
  description = "Map of client name to Cognito app client ID."
  value       = { for k, c in aws_cognito_user_pool_client.clients : k => c.id }
}

output "client_secrets" {
  description = "Map of client name to client secret (only set where generate_secret was true)."
  value       = { for k, c in aws_cognito_user_pool_client.clients : k => c.client_secret }
  sensitive   = true
}

output "cognito_domain" {
  description = "Cognito hosted UI domain (e.g. https://<domain>.auth.<region>.amazoncognito.com)."
  value       = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.region}.amazoncognito.com"
}

output "cognito_domain_prefix" {
  description = "Domain prefix used for the Cognito hosted UI."
  value       = aws_cognito_user_pool_domain.main.domain
}

output "supported_identity_providers" {
  description = "Identity providers enabled on the app client(s). Nonsensitive: provider names only (not IdP secrets)."
  value       = nonsensitive(local.supported_identity_providers)
}

data "aws_region" "current" {}
