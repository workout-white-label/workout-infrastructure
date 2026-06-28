variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production, staging)."
  type        = string
}

variable "name_suffix" {
  description = "Suffix for the internal ALB name."
  type        = string
  default     = "internal"
}

variable "vpc_id" {
  description = "VPC ID for the internal ALB."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the internal ALB."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID attached to the internal ALB."
  type        = string
}

variable "listener_port" {
  description = "HTTP listener port."
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags to apply to ALB resources."
  type        = map(string)
  default     = {}
}
