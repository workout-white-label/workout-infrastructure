variable "repository_name" {
  description = "ECR repository name."
  type        = string
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Scan images on push."
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to retain (0 disables lifecycle policy)."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to the repository."
  type        = map(string)
  default     = {}
}
