variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production, staging)."
  type        = string
}

variable "service_name" {
  description = "Short service name used in resource identifiers (e.g. user-manager)."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the database is deployed."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the DB subnet group (minimum two AZs)."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to PostgreSQL (port 5432)."
  type        = list(string)
}

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
}

variable "db_username" {
  description = "Master username for the database."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version (major.minor)."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage for autoscaling in GiB. Set to 0 to disable autoscaling."
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection on the RDS instance."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when the instance is destroyed."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the instance has a public IP address."
  type        = bool
  default     = false
}

variable "credentials_secret_path" {
  description = "Secrets Manager path for database credentials. Defaults to {project}/{environment}/{service}/database/credentials (console groups secrets by '/')."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to RDS resources."
  type        = map(string)
  default     = {}
}
