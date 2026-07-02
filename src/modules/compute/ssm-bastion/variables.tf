variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "VPC where the bastion is placed (platform VPC)."
  type        = string
}

variable "subnet_id" {
  description = "Private subnet ID (must have NAT or SSM VPC endpoints)."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the bastion."
  type        = string
  default     = "t4g.nano"
}

variable "postgres_egress_cidr_blocks" {
  description = "CIDR blocks the bastion may reach on port 5432 (e.g. datastore VPC)."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
