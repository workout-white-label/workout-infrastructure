output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 state bucket."
  value       = aws_s3_bucket.state.arn
}

output "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking."
  value       = aws_dynamodb_table.locks.name
}

output "lock_table_arn" {
  description = "ARN of the DynamoDB lock table."
  value       = aws_dynamodb_table.locks.arn
}

output "aws_region" {
  description = "AWS region where state bucket and lock table live."
  value       = var.aws_region
}
