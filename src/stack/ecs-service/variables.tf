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
  description = "Microservice identifier (e.g. user-manager)."
  type        = string
}

variable "github_repository" {
  description = "GitHub org/repo for OIDC deploy role trust."
  type        = string
}

variable "github_deploy_branches" {
  type    = list(string)
  default = ["main"]
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform remote state."
  type        = string
}

variable "terraform_state_region" {
  type    = string
  default = "eu-west-1"
}

variable "platform_state_key" {
  type    = string
  default = "platform/production/terraform.tfstate"
}

variable "identity_state_key" {
  description = "Optional identity stack key for Cognito user pool ID."
  type        = string
  default     = "identity/production/terraform.tfstate"
}

variable "cognito_user_pool_id" {
  description = "Override Cognito user pool ID instead of reading identity state."
  type        = string
  default     = ""
}

variable "create_database" {
  description = "Create a dedicated VPC + RDS for this service (includes VPC peering to platform)."
  type        = bool
  default     = false
}

variable "enable_database_peering" {
  description = "Peer to an existing database stack (use datastore_state_key)."
  type        = bool
  default     = false
}

variable "datastore_state_key" {
  description = "S3 state key of an existing database when enable_database_peering = true."
  type        = string
  default     = ""
}

variable "database_port" {
  type    = number
  default = 5432
}

variable "database" {
  description = "Database settings when create_database = true."
  type = object({
    vpc_cidr                = string
    private_subnet_cidrs    = list(string)
    db_name                 = string
    db_username             = string
    engine_version          = optional(string, "16")
    instance_class          = optional(string, "db.t4g.micro")
    allocated_storage       = optional(number, 20)
    max_allocated_storage   = optional(number, 100)
    multi_az                = optional(bool, false)
    backup_retention_period = optional(number, 7)
    deletion_protection     = optional(bool, true)
    skip_final_snapshot     = optional(bool, false)
    publicly_accessible     = optional(bool, false)
    credentials_secret_path = optional(string, "")
  })
  default = null

  validation {
    condition     = !var.create_database || var.database != null
    error_message = "database object is required when create_database = true."
  }
}

variable "ecr_repository_name" {
  type    = string
  default = null
}

variable "bootstrap_container_image" {
  type    = string
  default = null
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "alb_listener_priority" {
  description = "Unique priority on the shared internal ALB listener."
  type        = number
}

variable "alb_path_patterns" {
  type = list(string)
}

variable "health_check_path" {
  type    = string
  default = "/actuator/health"
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "container_secrets" {
  type = list(object({
    name       = string
    secret_arn = string
    json_key   = string
  }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
