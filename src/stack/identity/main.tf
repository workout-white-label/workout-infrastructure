terraform {
  required_version = ">= 1.14.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # All S3 backend settings (bucket, region, key, encrypt, use_lockfile) live in
  # backend.hcl so nothing deprecated (e.g. dynamodb_table) can linger in a merged config.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "cognito" {
  source = "../../modules/cognito"

  project_name   = var.project_name
  environment    = var.environment
  user_pool_name = var.user_pool_name

  username_attributes        = var.username_attributes
  auto_verified_attributes   = var.auto_verified_attributes
  password_policy_min_length = var.password_policy_min_length

  clients                        = var.clients
  allow_cognito_native_sign_in   = var.allow_cognito_native_sign_in
  google_idp                     = var.google_idp
  facebook_idp                   = var.facebook_idp
  apple_idp                      = var.apple_idp
  oidc_identity_providers        = var.oidc_identity_providers
  explicit_auth_flows            = var.explicit_auth_flows

  cognito_domain_prefix = var.cognito_domain_prefix

  tags = var.tags
}
