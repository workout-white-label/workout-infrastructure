output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "IDs of private subnets."
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidr_blocks" {
  description = "CIDR blocks of private subnets."
  value       = aws_subnet.private[*].cidr_block
}

output "availability_zones" {
  description = "Availability zones used by private subnets."
  value       = aws_subnet.private[*].availability_zone
}
