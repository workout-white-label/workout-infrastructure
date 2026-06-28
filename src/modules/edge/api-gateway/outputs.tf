output "api_id" {
  description = "API Gateway HTTP API ID."
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "Public invoke URL for the API Gateway stage."
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "vpc_link_id" {
  description = "VPC Link v2 ID."
  value       = aws_apigatewayv2_vpc_link.main.id
}

output "vpc_link_arn" {
  description = "VPC Link v2 ARN."
  value       = aws_apigatewayv2_vpc_link.main.arn
}
