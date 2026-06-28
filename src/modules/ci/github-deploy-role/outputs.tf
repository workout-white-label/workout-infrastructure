output "role_arn" {
  description = "ARN of the GitHub Actions deploy IAM role."
  value       = aws_iam_role.github_deploy.arn
}

output "role_name" {
  description = "Name of the GitHub Actions deploy IAM role."
  value       = aws_iam_role.github_deploy.name
}
