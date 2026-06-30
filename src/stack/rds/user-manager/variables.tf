variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "project_name" {
  type    = string
  default = "workout"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "service_name" {
  description = "Microservice identifier (user-manager)."
  type        = string
  default     = "user-manager"
}

variable "vpc_cidr" {
  description = "Dedicated datastore VPC CIDR (must not overlap platform VPC 10.10.0.0/16)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "db_name" {
  description = "PostgreSQL database name (matches application-local.properties)."
  type        = string
  default     = "user_manager"
}

variable "db_username" {
  description = "PostgreSQL master username."
  type        = string
  default     = "user_manager"
}

variable "engine_version" {
  type    = string
  default = "16"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "max_allocated_storage" {
  type    = number
  default = 100
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "credentials_secret_path" {
  description = "Secrets Manager path for JDBC credentials consumed by ECS."
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
