variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. production, staging)."
  type        = string
}

variable "user_pool_name" {
  description = "Display name for the Cognito user pool."
  type        = string
  default     = ""
}

variable "username_attributes" {
  description = "Attributes used as the unique username (e.g. email)."
  type        = list(string)
  default     = ["email"]
}

variable "auto_verified_attributes" {
  description = "Attributes to auto-verify (e.g. email)."
  type        = list(string)
  default     = ["email"]
}

variable "password_policy_min_length" {
  description = "Minimum password length (for native COGNITO sign-in only)."
  type        = number
  default     = 12
}

variable "clients" {
  description = "Map of Cognito user pool clients. Key = client name, value includes OAuth settings for Hosted UI / social sign-in."
  type = map(object({
    generate_secret                      = optional(bool, false)
    callback_urls                        = optional(list(string), [])
    logout_urls                          = optional(list(string), [])
    allowed_oauth_flows                  = optional(list(string), ["code"])
    allowed_oauth_scopes                 = optional(list(string), ["openid", "email", "profile"])
    allowed_oauth_flows_user_pool_client = optional(bool, true)
  }))
  default = {}
}

variable "allow_cognito_native_sign_in" {
  description = "If true, include COGNITO in supported_identity_providers (email/password on Hosted UI). Default true so apply works before federated IdPs are configured; set false for federated-only once IdPs are set."
  type        = bool
  default     = true
}

variable "google_idp" {
  description = "Google OAuth client (console.cloud.google.com). Set null to disable."
  type = object({
    client_id     = string
    client_secret = string
  })
  default  = null
  nullable = true
}

variable "facebook_idp" {
  description = "Facebook app credentials (developers.facebook.com). Set null to disable."
  type = object({
    client_id     = string
    client_secret = string
  })
  default  = null
  nullable = true
}

variable "apple_idp" {
  description = "Sign in with Apple (developer.apple.com). Set null to disable."
  type = object({
    client_id        = string
    team_id          = string
    key_id           = string
    private_key      = string
    authorize_scopes = optional(string, "email openid")
  })
  default  = null
  nullable = true
}

variable "oidc_identity_providers" {
  description = "Extra OIDC IdPs (e.g. X/Twitter if your app exposes OIDC). Map key = Cognito provider name shown in Hosted UI (e.g. \"X\"). AWS has no built-in X IdP."
  type = map(object({
    client_id        = string
    client_secret    = string
    oidc_issuer      = string
    authorize_scopes = optional(string, "openid email profile")
  }))
  default = {}
}

variable "explicit_auth_flows" {
  description = "Auth flows for each client. Hosted UI works with SRP + refresh; include ALLOW_USER_PASSWORD_AUTH if allow_cognito_native_sign_in is true."
  type        = list(string)
  default     = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
}

variable "cognito_domain_prefix" {
  description = "Prefix for the Cognito hosted UI domain (must be unique in the region)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to Cognito resources."
  type        = map(string)
  default     = {}
}
