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
  description = "Minimum password length."
  type        = number
  default     = 12
}

variable "clients" {
  description = "Map of Cognito user pool clients. Key = client name (e.g. app, web), value = { generate_secret = bool }. Each client is named <project>-<environment>-<key>."
  type = map(object({
    generate_secret = optional(bool, false)
  }))
  default = {}
}

variable "supported_identity_providers" {
  description = "Identity providers enabled for each client."
  type        = list(string)
  default     = ["COGNITO"]
}

variable "explicit_auth_flows" {
  description = "Auth flows allowed for each client."
  type        = list(string)
  default     = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
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
