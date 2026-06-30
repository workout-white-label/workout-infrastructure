variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "manage_github_oidc_provider" {
  description = "Create the GitHub OIDC provider. Set false if it already exists in the account (e.g. after migrating from github-oidc stack)."
  type        = bool
  default     = true
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform remote state (from bootstrap output)."
  type        = string
}

variable "aws_region" {
  description = "AWS region for IAM policy ARNs."
  type        = string
}

variable "github_ecs_service_terraform_repositories" {
  description = "App repos allowed to run ecs-service Terraform in CI (org/repo)."
  type        = list(string)
  default     = []
}

