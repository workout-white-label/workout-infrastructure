output "peering_connection_id" {
  description = "ID of the VPC peering connection."
  value       = aws_vpc_peering_connection.main.id
}
