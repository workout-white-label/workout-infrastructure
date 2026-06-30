terraform {
  required_version = ">= 1.14.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project      = var.project_name
    Environment  = var.environment
    Microservice = var.service_name
    Layer        = "datastore"
    ManagedBy    = "terraform"
  })
}

module "database_vpc" {
  source = "../../../modules/vpc/vpc-datastore"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "database" {
  source = "../../../modules/data/rds"

  project_name = var.project_name
  environment  = var.environment
  service_name = var.service_name

  vpc_id     = module.database_vpc.vpc_id
  subnet_ids = module.database_vpc.private_subnet_ids

  db_name                 = var.db_name
  db_username             = var.db_username
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = var.publicly_accessible
  credentials_secret_path = var.credentials_secret_path

  tags = local.common_tags
}
