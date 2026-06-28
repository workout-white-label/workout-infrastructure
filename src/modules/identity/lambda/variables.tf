variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production, staging)."
  type        = string
}

variable "function_name" {
  description = "Lambda function name suffix (full name: {project}-{environment}-{function_name})."
  type        = string
}

variable "handler_path" {
  description = "Path to the built Lambda handler file (handler.js)."
  type        = string
}

variable "handler" {
  description = "Lambda handler entrypoint."
  type        = string
  default     = "handler.handler"
}

variable "runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "nodejs24.x"
}

variable "timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 5
}

variable "memory_size" {
  description = "Lambda memory in MB."
  type        = number
  default     = 128
}

variable "log_retention_in_days" {
  description = "CloudWatch log group retention in days."
  type        = number
  default     = 14
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to Lambda resources."
  type        = map(string)
  default     = {}
}
