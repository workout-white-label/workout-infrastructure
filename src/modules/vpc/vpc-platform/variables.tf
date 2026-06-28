variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production, staging)."
  type        = string
}

variable "name_suffix" {
  description = "Suffix for the VPC name (e.g. platform)."
  type        = string
  default     = "platform"
}

variable "vpc_cidr" {
  description = "CIDR block for the platform VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (one per AZ; used for NAT gateways)."
  type        = list(string)
  default     = ["10.10.101.0/24", "10.10.102.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for ECS tasks and internal ALB (one per AZ)."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all private subnets (lower cost)."
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Create interface endpoints for ECR, CloudWatch Logs, and Secrets Manager."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to VPC resources."
  type        = map(string)
  default     = {}
}
