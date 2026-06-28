output "db_instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance."
  value       = aws_db_instance.main.arn
}

output "db_endpoint" {
  description = "Connection endpoint (hostname)."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "PostgreSQL port."
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name."
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Master database username."
  value       = aws_db_instance.main.username
}

output "db_security_group_id" {
  description = "Security group ID attached to the RDS instance."
  value       = aws_security_group.db.id
}

output "db_subnet_group_name" {
  description = "DB subnet group name."
  value       = aws_db_subnet_group.main.name
}

output "credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret with database credentials and JDBC URL."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "credentials_secret_name" {
  description = "Secrets Manager path/name for database credentials (e.g. workout/production/user-manager/database/credentials)."
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "credentials_secret_path" {
  description = "Same as credentials_secret_name; hierarchical path for IAM policies and console navigation."
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "jdbc_url" {
  description = "JDBC URL for Spring Boot (password is in Secrets Manager)."
  value       = "jdbc:postgresql://${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
}
