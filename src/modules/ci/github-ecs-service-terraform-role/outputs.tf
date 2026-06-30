output "role_arn" {
  description = "ARN of the GitHub Actions IAM role for ecs-service Terraform."
  value       = aws_iam_role.github_terraform.arn
}

output "role_name" {
  description = "Name of the GitHub Actions IAM role for ecs-service Terraform."
  value       = aws_iam_role.github_terraform.name
}
