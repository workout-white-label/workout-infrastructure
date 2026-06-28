variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production, staging)."
  type        = string
}

variable "name_suffix" {
  description = "Suffix for the API Gateway name."
  type        = string
  default     = "platform"
}

variable "subnet_ids" {
  description = "Private subnet IDs for the VPC Link ENIs."
  type        = list(string)
}

variable "vpc_link_security_group_ids" {
  description = "Security group IDs for the VPC Link."
  type        = list(string)
}

variable "alb_listener_arn" {
  description = "ARN of the internal ALB HTTP listener (required for VPC Link v2 integrations)."
  type        = string
}

variable "cors_allow_origins" {
  description = "Allowed origins for API Gateway CORS."
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to API Gateway resources."
  type        = map(string)
  default     = {}
}
