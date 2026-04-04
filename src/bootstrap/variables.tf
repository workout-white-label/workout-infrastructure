variable "project_name" {
  description = "Project name used for S3 bucket and DynamoDB table names (must be globally unique for S3)."
  type        = string
  default     = "workout-infrastructure"
}

variable "aws_region" {
  description = "AWS region for the state bucket and DynamoDB table."
  type        = string
  default     = "eu-west-1"
}
