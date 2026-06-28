variable "aws_region" {
  description = "AWS region for the platform stack."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production)."
  type        = string
}

variable "manage_github_oidc_provider" {
  description = "Create GitHub OIDC provider in this stack. Set false if it already exists in the account."
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "CIDR for the platform VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs for NAT gateways."
  type        = list(string)
  default     = ["10.10.101.0/24", "10.10.102.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for ECS, internal ALB, and VPC Link."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all private subnets."
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Create VPC interface endpoints for ECR, Logs, and Secrets Manager."
  type        = bool
  default     = true
}

variable "alb_listener_port" {
  description = "HTTP port on the internal ALB."
  type        = number
  default     = 80
}

variable "cors_allow_origins" {
  description = "CORS allowed origins on the public API Gateway."
  type        = list(string)
  default     = ["*"]
}

variable "enable_container_insights" {
  description = "Enable ECS Container Insights on the cluster."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for platform resources."
  type        = map(string)
  default     = {}
}
