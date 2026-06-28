variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "manage_github_oidc_provider" {
  description = "Create the GitHub OIDC provider. Set false if it already exists in the account (e.g. after migrating from github-oidc stack)."
  type        = bool
  default     = true
}
