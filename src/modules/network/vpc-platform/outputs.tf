output "vpc_id" {
  description = "Platform VPC ID."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "Platform VPC CIDR block."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (ECS, internal ALB, VPC Link)."
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs."
  value       = aws_nat_gateway.main[*].id
}

output "private_route_table_ids" {
  description = "Route table IDs for private subnets."
  value       = aws_route_table.private[*].id
}

output "public_route_table_id" {
  description = "Route table ID for public subnets."
  value       = aws_route_table.public.id
}
