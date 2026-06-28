terraform {
  required_version = ">= 1.14.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    Layer       = "platform"
    ManagedBy   = "terraform"
  })
}

# -----------------------------------------------------------------------------
# Platform VPC + ECS Fargate cluster
# -----------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/platform-vpc"

  project_name         = var.project_name
  environment          = var.environment
  name_suffix          = "platform"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  enable_vpc_endpoints = var.enable_vpc_endpoints
  tags                 = var.tags
}

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project_name              = var.project_name
  environment               = var.environment
  name_suffix               = "platform"
  enable_container_insights = var.enable_container_insights
  tags                      = var.tags
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${local.name_prefix}-ecs-tasks"
  description = "ECS Fargate tasks for Workout microservices"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-ecs-tasks"
    Component = "ecs-tasks"
  })
}

# -----------------------------------------------------------------------------
# Internal ALB (private, for ECS services)
# -----------------------------------------------------------------------------

resource "aws_security_group" "vpc_link" {
  name        = "${local.name_prefix}-vpc-link"
  description = "API Gateway VPC Link ENIs to internal ALB"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-vpc-link"
    Component = "api-gateway-vpc-link"
  })
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-internal-alb"
  description = "Internal ALB for Workout microservices"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-internal-alb"
    Component = "internal-alb"
  })
}

resource "aws_security_group_rule" "vpc_link_to_alb" {
  type                     = "egress"
  description              = "HTTP to internal ALB"
  from_port                = var.alb_listener_port
  to_port                  = var.alb_listener_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_link.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_from_vpc_link" {
  type                     = "ingress"
  description              = "HTTP from API Gateway VPC Link"
  from_port                = var.alb_listener_port
  to_port                  = var.alb_listener_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.vpc_link.id
}

resource "aws_security_group_rule" "alb_from_vpc" {
  type              = "ingress"
  description       = "HTTP from within the platform VPC"
  from_port         = var.alb_listener_port
  to_port           = var.alb_listener_port
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = [module.vpc.vpc_cidr_block]
}

resource "aws_security_group_rule" "alb_to_ecs_tasks" {
  type                     = "egress"
  description              = "To ECS task containers"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "ecs_tasks_from_alb" {
  type                     = "ingress"
  description              = "From internal ALB"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.alb.id
}

module "internal_alb" {
  source = "../../modules/internal-alb"

  project_name      = var.project_name
  environment       = var.environment
  name_suffix       = "internal"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = aws_security_group.alb.id
  listener_port     = var.alb_listener_port
  tags              = var.tags
}

# -----------------------------------------------------------------------------
# API Gateway HTTP API + VPC Link v2
# -----------------------------------------------------------------------------

module "api_gateway" {
  source = "../../modules/api-gateway"

  project_name                = var.project_name
  environment                 = var.environment
  name_suffix                 = "platform"
  subnet_ids                  = module.vpc.private_subnet_ids
  vpc_link_security_group_ids = [aws_security_group.vpc_link.id]
  alb_listener_arn            = module.internal_alb.listener_arn
  cors_allow_origins          = var.cors_allow_origins
  tags                        = var.tags

  depends_on = [module.internal_alb]
}
