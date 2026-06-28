output "alb_arn" {
  description = "ARN of the internal application load balancer."
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the internal ALB (used by API Gateway VPC Link integration)."
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Route53 zone ID of the internal ALB."
  value       = aws_lb.main.zone_id
}

output "listener_arn" {
  description = "ARN of the default HTTP listener."
  value       = aws_lb_listener.http.arn
}
