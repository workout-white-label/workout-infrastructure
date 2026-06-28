variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production)."
  type        = string
}

variable "domain_name" {
  description = "Custom domain served by CloudFront (e.g. workout.julianosena.com)."
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for DNS validation and the CloudFront alias record."
  type        = string
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}
