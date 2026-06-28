variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production, staging)."
  type        = string
}

variable "name_suffix" {
  description = "Suffix for the ECS cluster name."
  type        = string
  default     = "platform"
}

variable "enable_container_insights" {
  description = "Enable ECS Container Insights."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to ECS resources."
  type        = map(string)
  default     = {}
}
