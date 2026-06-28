variable "role_name" {
  description = "IAM role name for GitHub Actions deploy."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in org/repo form."
  type        = string
}

variable "github_branches" {
  description = "Branches allowed to assume the deploy role."
  type        = list(string)
  default     = ["main"]
}

variable "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider in this AWS account."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN this role may push to."
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ECS cluster ARN."
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name to update on deploy."
  type        = string
}

variable "task_execution_role_arn" {
  description = "ECS task execution role ARN (for iam:PassRole)."
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN (for iam:PassRole)."
  type        = string
}

variable "tags" {
  description = "Tags for the IAM role."
  type        = map(string)
  default     = {}
}
