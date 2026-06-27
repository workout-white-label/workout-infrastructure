output "vpc_id" {
  description = "VPC ID for user-manager."
  value       = module.vpc.vpc_id
}

output "app_security_group_id" {
  description = "Security group for user-manager application compute (attach to ECS/EC2)."
  value       = aws_security_group.app.id
}

output "db_endpoint" {
  description = "RDS hostname."
  value       = module.database.db_endpoint
}

output "db_port" {
  description = "PostgreSQL port."
  value       = module.database.db_port
}

output "db_name" {
  description = "Database name."
  value       = module.database.db_name
}

output "db_username" {
  description = "Master database username."
  value       = module.database.db_username
}

output "jdbc_url" {
  description = "JDBC URL for Spring Boot (password is in Secrets Manager)."
  value       = module.database.jdbc_url
}

output "credentials_secret_arn" {
  description = "Secrets Manager ARN for user-manager database credentials."
  value       = module.database.credentials_secret_arn
}

output "credentials_secret_name" {
  description = "Secrets Manager path for user-manager database credentials."
  value       = module.database.credentials_secret_name
}

output "credentials_secret_path" {
  description = "Hierarchical Secrets Manager path (workout/production/user-manager/database/credentials)."
  value       = module.database.credentials_secret_path
}

output "db_security_group_id" {
  description = "RDS security group ID."
  value       = module.database.db_security_group_id
}
