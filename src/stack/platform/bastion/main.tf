variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "postgres_egress_cidr_blocks" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

module "ssm_bastion" {
  source = "../../../modules/compute/ssm-bastion"

  project_name                = var.project_name
  environment                 = var.environment
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  instance_type               = var.instance_type
  postgres_egress_cidr_blocks = var.postgres_egress_cidr_blocks
  tags                        = var.tags
}
