variable "role_name" {
  description = "IAM role name for GitHub Actions ecs-service Terraform."
  type        = string
}

variable "github_repositories" {
  description = "GitHub repositories (org/repo) allowed to run ecs-service Terraform."
  type        = list(string)
}

variable "github_branches" {
  description = "Branches allowed to assume this role."
  type        = list(string)
  default     = ["main"]
}

variable "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider in this AWS account."
  type        = string
}

variable "state_bucket_name" {
  description = "S3 bucket that stores Terraform remote state."
  type        = string
}

variable "ecs_service_state_prefix" {
  description = "S3 key prefix for ecs-service stack state objects."
  type        = string
  default     = "ecs-service/"
}

variable "remote_state_prefixes" {
  description = "S3 key prefixes this role may read for terraform_remote_state."
  type        = list(string)
  default     = ["platform/", "identity/", "rds/"]
}

variable "resource_name_prefix" {
  description = "Prefix for IAM roles and other named resources created by ecs-service (e.g. workout-production)."
  type        = string
}

variable "aws_region" {
  description = "AWS region for ARN-scoped permissions."
  type        = string
}

variable "tags" {
  description = "Tags for the IAM role."
  type        = map(string)
  default     = {}
}
