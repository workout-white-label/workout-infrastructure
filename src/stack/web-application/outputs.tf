output "bucket_name" {
  description = "Private S3 bucket for built frontend assets."
  value       = module.static_site.bucket_name
}

output "bucket_arn" {
  description = "ARN of the frontend S3 bucket."
  value       = module.static_site.bucket_arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.static_site.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (*.cloudfront.net)."
  value       = module.static_site.cloudfront_domain_name
}

output "website_url" {
  description = "Public HTTPS URL for the frontend."
  value       = module.static_site.website_url
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1."
  value       = module.static_site.acm_certificate_arn
}
