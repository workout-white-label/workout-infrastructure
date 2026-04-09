locals {
  name_prefix   = "${var.project_name}-${var.environment}"
  pool_name     = coalesce(var.user_pool_name, "${local.name_prefix}-users")
  domain_prefix = coalesce(var.cognito_domain_prefix, replace("${local.name_prefix}-auth", "_", "-"))
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })

  idp_google   = var.google_idp != null ? ["Google"] : []
  idp_facebook = var.facebook_idp != null ? ["Facebook"] : []
  idp_apple    = var.apple_idp != null ? ["SignInWithApple"] : []
  idp_oidc     = keys(var.oidc_identity_providers)

  cognito_native = var.allow_cognito_native_sign_in ? ["COGNITO"] : []

  supported_identity_providers = concat(
    local.cognito_native,
    local.idp_google,
    local.idp_facebook,
    local.idp_apple,
    local.idp_oidc
  )
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

resource "aws_cognito_identity_provider" "google" {
  count = var.google_idp != null ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_idp.client_id
    client_secret    = var.google_idp.client_secret
    authorize_scopes = "openid email profile"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
    name     = "name"
  }
}

resource "aws_cognito_identity_provider" "facebook" {
  count = var.facebook_idp != null ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Facebook"
  provider_type = "Facebook"

  provider_details = {
    client_id        = var.facebook_idp.client_id
    client_secret    = var.facebook_idp.client_secret
    authorize_scopes = "public_profile,email"
  }

  attribute_mapping = {
    email    = "email"
    username = "id"
    name     = "name"
  }
}

resource "aws_cognito_identity_provider" "apple" {
  count = var.apple_idp != null ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "SignInWithApple"
  provider_type = "SignInWithApple"

  provider_details = {
    client_id        = var.apple_idp.client_id
    team_id          = var.apple_idp.team_id
    key_id           = var.apple_idp.key_id
    private_key      = var.apple_idp.private_key
    authorize_scopes = coalesce(var.apple_idp.authorize_scopes, "email openid")
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

resource "aws_cognito_identity_provider" "oidc" {
  for_each = var.oidc_identity_providers

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = each.key
  provider_type = "OIDC"

  provider_details = {
    client_id        = each.value.client_id
    client_secret    = each.value.client_secret
    oidc_issuer      = each.value.oidc_issuer
    authorize_scopes = coalesce(each.value.authorize_scopes, "openid email profile")
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

resource "aws_cognito_user_pool_client" "clients" {
  for_each = var.clients

  name         = "${local.name_prefix}-${each.key}"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = each.value.generate_secret

  supported_identity_providers = local.supported_identity_providers
  explicit_auth_flows          = var.explicit_auth_flows

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

  allowed_oauth_flows_user_pool_client = length(each.value.callback_urls) > 0 ? coalesce(each.value.allowed_oauth_flows_user_pool_client, true) : false
  allowed_oauth_flows                  = length(each.value.callback_urls) > 0 ? each.value.allowed_oauth_flows : null
  allowed_oauth_scopes                 = length(each.value.callback_urls) > 0 ? each.value.allowed_oauth_scopes : null
  callback_urls                        = length(each.value.callback_urls) > 0 ? each.value.callback_urls : null
  logout_urls                          = length(each.value.logout_urls) > 0 ? each.value.logout_urls : null

  # Cognito rejects supported_identity_providers until IdP resources exist (and may race parallel applies).
  depends_on = [
    aws_cognito_identity_provider.google,
    aws_cognito_identity_provider.facebook,
    aws_cognito_identity_provider.apple,
    aws_cognito_identity_provider.oidc,
  ]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = local.domain_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}

check "at_least_one_identity_provider" {
  assert {
    condition     = length(local.supported_identity_providers) > 0
    error_message = "Enable at least one sign-in option: set allow_cognito_native_sign_in = true and/or configure google_idp, facebook_idp, apple_idp, or oidc_identity_providers."
  }
}
