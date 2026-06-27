variable "aws_region" {
  description = "AWS region for RDS."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC used by this database."
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for the RDS subnet group (minimum two AZs)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "db_name" {
  description = "PostgreSQL database name (matches workout-user-manager Flyway migrations)."
  type        = string
  default     = "user_manager"
}

variable "db_username" {
  description = "Master database username."
  type        = string
  default     = "user_manager"
}

variable "engine_version" {
  description = "PostgreSQL major version (workout-user-manager uses PostgreSQL 16)."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max storage for autoscaling in GiB (0 disables)."
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable Multi-AZ for high availability."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Automated backup retention in days."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Prevent accidental RDS deletion."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy (use false in production)."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Assign a public IP to RDS (keep false; app connects from VPC)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for database resources."
  type        = map(string)
  default     = {}
}
