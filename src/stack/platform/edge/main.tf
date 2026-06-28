variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_listener_port" {
  type = number
}

variable "cors_allow_origins" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${local.name_prefix}-ecs-tasks"
  description = "ECS Fargate tasks for Workout microservices"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name      = "${local.name_prefix}-ecs-tasks"
    Component = "ecs-tasks"
  })
}

resource "aws_security_group" "vpc_link" {
  name        = "${local.name_prefix}-vpc-link"
  description = "API Gateway VPC Link ENIs to internal ALB"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name      = "${local.name_prefix}-vpc-link"
    Component = "api-gateway-vpc-link"
  })
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-internal-alb"
  description = "Internal ALB for Workout microservices"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
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
  cidr_blocks       = [var.vpc_cidr_block]
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
  source = "../../../modules/internal-alb"

  project_name      = var.project_name
  environment       = var.environment
  name_suffix       = "internal"
  vpc_id            = var.vpc_id
  subnet_ids        = var.private_subnet_ids
  security_group_id = aws_security_group.alb.id
  listener_port     = var.alb_listener_port
  tags              = var.tags
}

module "api_gateway" {
  source = "../../../modules/api-gateway"

  project_name                = var.project_name
  environment                 = var.environment
  name_suffix                 = "platform"
  subnet_ids                  = var.private_subnet_ids
  vpc_link_security_group_ids = [aws_security_group.vpc_link.id]
  alb_listener_arn            = module.internal_alb.listener_arn
  cors_allow_origins          = var.cors_allow_origins
  tags                        = var.tags

  depends_on = [module.internal_alb]
}
