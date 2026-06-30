output "vpc_id" {
  description = "Datastore VPC ID (for ecs-service peering)."
  value       = module.database_vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "Datastore VPC CIDR (for ecs-service peering routes)."
  value       = module.database_vpc.vpc_cidr_block
}

output "private_route_table_id" {
  description = "Private route table in the datastore VPC."
  value       = module.database_vpc.private_route_table_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs in the datastore VPC."
  value       = module.database_vpc.private_subnet_ids
}

output "db_instance_id" {
  value = module.database.db_instance_id
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "db_port" {
  value = module.database.db_port
}

output "db_name" {
  value = module.database.db_name
}

output "db_security_group_id" {
  description = "RDS security group (ecs-service adds platform CIDR ingress when peering)."
  value       = module.database.db_security_group_id
}

output "credentials_secret_arn" {
  description = "Secrets Manager ARN wired into ECS task secrets (jdbc_url, username, password)."
  value       = module.database.credentials_secret_arn
}

output "credentials_secret_path" {
  value = module.database.credentials_secret_path
}

output "jdbc_url" {
  value = module.database.jdbc_url
}
