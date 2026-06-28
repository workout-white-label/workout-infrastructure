variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "single_nat_gateway" {
  type = bool
}

variable "enable_vpc_endpoints" {
  type = bool
}

variable "tags" {
  type = map(string)
}

module "vpc" {
  source = "../../../modules/platform-vpc"

  project_name         = var.project_name
  environment          = var.environment
  name_suffix          = "platform"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  enable_vpc_endpoints = var.enable_vpc_endpoints
  tags                 = var.tags
}
