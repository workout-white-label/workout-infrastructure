terraform {
  required_version = ">= 1.14.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    key     = "identity/production/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "cognito" {
  source = "../../modules/cognito"

  project_name   = var.project_name
  environment    = var.environment
  user_pool_name = var.user_pool_name

  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes
  password_policy_min_length = var.password_policy_min_length

  clients             = var.clients
  explicit_auth_flows = var.explicit_auth_flows

  cognito_domain_prefix = var.cognito_domain_prefix

  tags = var.tags
}
