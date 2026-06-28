variable "name" {
  description = "Name tag for the VPC peering connection."
  type        = string
}

variable "requester_vpc_id" {
  description = "VPC ID of the requester (typically the platform / compute VPC)."
  type        = string
}

variable "accepter_vpc_id" {
  description = "VPC ID of the accepter (typically the data / RDS VPC)."
  type        = string
}

variable "requester_route_table_ids" {
  description = "Route table IDs in the requester VPC that need routes to the accepter CIDR."
  type        = list(string)
}

variable "accepter_route_table_ids" {
  description = "Route table IDs in the accepter VPC that need routes to the requester CIDR."
  type        = list(string)
}

variable "requester_cidr_block" {
  description = "CIDR block of the requester VPC."
  type        = string
}

variable "accepter_cidr_block" {
  description = "CIDR block of the accepter VPC."
  type        = string
}

variable "tags" {
  description = "Tags applied to the peering connection."
  type        = map(string)
  default     = {}
}
