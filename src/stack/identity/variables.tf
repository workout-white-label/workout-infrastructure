variable "aws_region" {
  description = "AWS region for Cognito and backend."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production)."
  type        = string
}

variable "user_pool_name" {
  description = "Display name for the Cognito user pool."
  type        = string
  default     = ""
}

variable "username_attributes" {
  description = "Attributes used as the unique username."
  type        = list(string)
  default     = ["email"]
}

variable "auto_verified_attributes" {
  description = "Attributes to auto-verify."
  type        = list(string)
  default     = ["email"]
}

variable "password_policy_min_length" {
  description = "Minimum password length (native sign-in only)."
  type        = number
  default     = 12
}

variable "clients" {
  description = "App clients. For a web app with social login, use one client (e.g. web) with callback_urls and logout_urls matching your app and Google/Facebook/Apple console redirect URIs."
  type = map(object({
    generate_secret                      = optional(bool, false)
    callback_urls                        = optional(list(string), [])
    logout_urls                          = optional(list(string), [])
    allowed_oauth_flows                  = optional(list(string), ["code"])
    allowed_oauth_scopes                 = optional(list(string), ["openid", "email", "profile"])
    allowed_oauth_flows_user_pool_client = optional(bool, true)
  }))
  default = {
    web = {
      generate_secret = false
      callback_urls   = ["http://localhost:3000/callback"]
      logout_urls     = ["http://localhost:3000"]
    }
  }
}

variable "allow_cognito_native_sign_in" {
  description = "If true, users can sign up/sign in with email and password on the Hosted UI. Default true until federated IdPs are configured; set false for federated-only (requires at least one of google_idp, facebook_idp, apple_idp, oidc_identity_providers)."
  type        = bool
  default     = true
}

variable "google_idp" {
  description = "Google OAuth 2.0 client (Google Cloud Console). Redirect URI must include https://<cognito-domain>/oauth2/idpresponse"
  type = object({
    client_id     = string
    client_secret = string
  })
  default  = null
  nullable = true
  sensitive = true
}

variable "facebook_idp" {
  description = "Facebook Login app (Meta for Developers)."
  type = object({
    client_id     = string
    client_secret = string
  })
  default  = null
  nullable = true
  sensitive = true
}

variable "apple_idp" {
  description = "Sign in with Apple (Services ID, key, team)."
  type = object({
    client_id        = string
    team_id          = string
    key_id           = string
    private_key      = string
    authorize_scopes = optional(string)
  })
  default  = null
  nullable = true
  sensitive = true
}

variable "oidc_identity_providers" {
  description = "OIDC IdPs (e.g. X). AWS Cognito has no built-in X/Twitter; configure only if your provider supports OIDC and you have issuer + client credentials."
  type = map(object({
    client_id        = string
    client_secret    = string
    oidc_issuer      = string
    authorize_scopes = optional(string)
  }))
  default = {}
  # Not marked sensitive: marking the whole map sensitive breaks for_each keys in the module.
}

variable "explicit_auth_flows" {
  description = "Cognito app client auth flows."
  type        = list(string)
  default     = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
}

variable "cognito_domain_prefix" {
  description = "Prefix for the Cognito hosted UI domain (unique in region)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags for Cognito resources."
  type        = map(string)
  default     = {}
}
