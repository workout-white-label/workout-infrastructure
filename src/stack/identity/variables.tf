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
  description = "Minimum password length."
  type        = number
  default     = 12
}

variable "clients" {
  description = "Map of Cognito app clients. Key = client name (e.g. app, web), value = { generate_secret = bool }. Each is named <project>-<environment>-<key>."
  type = map(object({
    generate_secret = optional(bool, false)
  }))
  default = {
    app  = { generate_secret = false }
    web  = { generate_secret = false }
  }
}

variable "explicit_auth_flows" {
  description = "Auth flows allowed for the app client."
  type        = list(string)
  default     = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
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
