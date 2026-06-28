locals {
  name_prefix = "${var.project_name}-${var.environment}"
  name        = "${local.name_prefix}-${var.name_suffix}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    Layer       = "platform"
    ManagedBy   = "terraform"
  })
}

resource "aws_ecs_cluster" "main" {
  name = local.name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.name}"
  retention_in_days = 30

  tags = local.common_tags
}
