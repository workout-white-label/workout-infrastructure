# ECS cluster only — per-microservice deploy runs from src/stack/ecs-service (git submodule in app repos).

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "enable_container_insights" {
  type = bool
}

variable "tags" {
  type = map(string)
}

module "ecs_cluster" {
  source = "../../../modules/compute/ecs-cluster"

  project_name              = var.project_name
  environment               = var.environment
  name_suffix               = "platform"
  enable_container_insights = var.enable_container_insights
  tags                      = var.tags
}
