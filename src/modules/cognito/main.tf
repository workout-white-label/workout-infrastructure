locals {
  name_prefix = "${var.project_name}-${var.environment}"
  pool_name   = coalesce(var.user_pool_name, "${local.name_prefix}-users")
  domain_prefix = coalesce(var.cognito_domain_prefix, replace("${local.name_prefix}-auth", "_", "-"))
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_cognito_user_pool" "main" {
  name = local.pool_name

  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes

  password_policy {
    minimum_length    = var.password_policy_min_length
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  tags = local.common_tags
}

resource "aws_cognito_user_pool_client" "clients" {
  for_each = var.clients

  name         = "${local.name_prefix}-${each.key}"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = each.value.generate_secret

  supported_identity_providers = var.supported_identity_providers
  explicit_auth_flows         = var.explicit_auth_flows

  refresh_token_validity = 30
  access_token_validity  = 60
  id_token_validity      = 60
  token_validity_units {
    refresh_token = "days"
    access_token  = "minutes"
    id_token      = "minutes"
  }

  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = local.domain_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}
