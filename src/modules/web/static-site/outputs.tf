output "bucket_name" {
  description = "Private S3 bucket for built frontend assets."
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "ARN of the frontend S3 bucket."
  value       = aws_s3_bucket.frontend.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (*.cloudfront.net)."
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN."
  value       = aws_cloudfront_distribution.frontend.arn
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1."
  value       = aws_acm_certificate.frontend.arn
}

output "website_url" {
  description = "Public HTTPS URL for the frontend."
  value       = "https://${var.domain_name}"
}
