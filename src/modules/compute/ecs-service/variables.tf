variable "project_name" {
  description = "Project name (e.g. workout)."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. production)."
  type        = string
}

variable "service_name" {
  description = "Microservice identifier used in resource names (e.g. user-manager)."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "cluster_arn" {
  description = "ECS cluster ARN."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the target group."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for ECS tasks."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for ECS task ENIs."
  type        = list(string)
}

variable "alb_listener_arn" {
  description = "ARN of the internal ALB HTTP listener."
  type        = string
}

variable "listener_priority" {
  description = "Priority for the ALB listener rule (must be unique per listener)."
  type        = number
}

variable "path_patterns" {
  description = "ALB path patterns that route traffic to this service."
  type        = list(string)
}

variable "container_image" {
  description = "Container image URI for the initial task definition."
  type        = string
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory (MiB)."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of running tasks."
  type        = number
  default     = 1
}

variable "environment_variables" {
  description = "Plain environment variables for the container."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of container environment variable name to Secrets Manager valueFrom ARN (including JSON key suffix)."
  type        = map(string)
  default     = {}
}

variable "secret_arns" {
  description = "Secrets Manager secret ARNs the task execution role may read."
  type        = list(string)
  default     = []
}

variable "log_group_name" {
  description = "CloudWatch log group for container logs."
  type        = string
}

variable "health_check_path" {
  description = "HTTP path for target group and container health checks."
  type        = string
  default     = "/actuator/health"
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore unhealthy target checks after a task starts."
  type        = number
  default     = 120
}

variable "assign_public_ip" {
  description = "Assign a public IP to task ENIs (false for private subnets with NAT)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
