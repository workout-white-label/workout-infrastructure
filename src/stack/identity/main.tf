terraform {
  required_version = ">= 1.14.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0"
    }
  }

  # All S3 backend settings (bucket, region, key, encrypt, use_lockfile) live in
  # backend.hcl so nothing deprecated (e.g. dynamodb_table) can linger in a merged config.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "cognito_pre_token_lambda" {
  source = "../../modules/lambda"

  project_name  = var.project_name
  environment   = var.environment
  function_name = "cognito-pre-token"
  handler_path  = abspath("${path.module}/../../lambdas/cognito-pre-token-generation/dist/handler.js")
  environment_variables = {
    USER_MANAGER_BASE_URL = var.user_manager_base_url
    INTERNAL_API_KEY      = var.internal_api_key
  }
  tags = var.tags
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

  pre_token_generation_lambda_arn     = module.cognito_pre_token_lambda.function_arn
  attach_pre_token_generation_trigger = var.attach_pre_token_generation_trigger

  tags = var.tags
}

# Cognito requires this permission before the user pool trigger is attached.
# Kept outside the cognito module to avoid a Terraform cycle (permission needs
# pool ARN; pool must not depend_on permission). If apply fails attaching the
# trigger, run apply again once this permission exists.
resource "aws_lambda_permission" "cognito_pre_token_generation" {
  statement_id  = "AllowCognitoPreTokenGeneration"
  action        = "lambda:InvokeFunction"
  function_name = module.cognito_pre_token_lambda.function_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito.user_pool_arn
}
