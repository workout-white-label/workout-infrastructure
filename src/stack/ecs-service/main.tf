terraform {
  required_version = ">= 1.14.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
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
    Project      = var.project_name
    Environment  = var.environment
    Microservice = var.service_name
    ManagedBy    = "terraform"
  })

  ecr_repository_name = coalesce(var.ecr_repository_name, "${local.name_prefix}-${var.service_name}")

  cognito_user_pool_id = var.cognito_user_pool_id != "" ? var.cognito_user_pool_id : try(
    data.terraform_remote_state.identity[0].outputs.user_pool_id,
    ""
  )

  database_secret_arn = var.create_database ? module.database[0].credentials_secret_arn : (
    var.enable_database_peering ? data.terraform_remote_state.datastore[0].outputs.credentials_secret_arn : ""
  )

  container_secrets = concat(
    var.create_database || var.enable_database_peering ? [
      { name = "DATABASE_URL", secret_arn = local.database_secret_arn, json_key = "jdbc_url" },
      { name = "DATABASE_USERNAME", secret_arn = local.database_secret_arn, json_key = "username" },
      { name = "DATABASE_PASSWORD", secret_arn = local.database_secret_arn, json_key = "password" },
    ] : [],
    var.container_secrets
  )

  secret_arns = distinct([for s in local.container_secrets : s.secret_arn])

  bootstrap_image = coalesce(
    var.bootstrap_container_image,
    "${module.ecr.repository_url}:bootstrap"
  )

  environment_variables = merge(
    { AWS_REGION = var.aws_region },
    local.cognito_user_pool_id != "" ? { COGNITO_USER_POOL_ID = local.cognito_user_pool_id } : {},
    var.environment_variables
  )
}

data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.platform_state_key
    region = var.terraform_state_region
  }
}

data "terraform_remote_state" "identity" {
  count = var.cognito_user_pool_id == "" && var.terraform_state_bucket != "" && var.identity_state_key != "" ? 1 : 0

  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.identity_state_key
    region = var.terraform_state_region
  }
}

data "terraform_remote_state" "datastore" {
  count = var.enable_database_peering && !var.create_database ? 1 : 0

  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = var.datastore_state_key
    region = var.terraform_state_region
  }
}

check "platform_prerequisites" {
  assert {
    condition     = data.terraform_remote_state.platform.outputs.internal_alb_listener_arn != null
    error_message = "Apply the platform stack before ecs-service."
  }
}

# --- Optional database (dedicated VPC + RDS + peering) ---

module "database_vpc" {
  count  = var.create_database ? 1 : 0
  source = "../../modules/vpc/vpc-datastore"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.database.vpc_cidr
  private_subnet_cidrs = var.database.private_subnet_cidrs
  tags                 = local.common_tags
}

module "database" {
  count  = var.create_database ? 1 : 0
  source = "../../modules/data/rds"

  project_name        = var.project_name
  environment         = var.environment
  service_name        = var.service_name
  vpc_id              = module.database_vpc[0].vpc_id
  subnet_ids          = module.database_vpc[0].private_subnet_ids
  allowed_cidr_blocks = [data.terraform_remote_state.platform.outputs.vpc_cidr_block]

  db_name                 = var.database.db_name
  db_username             = var.database.db_username
  engine_version          = var.database.engine_version
  instance_class          = var.database.instance_class
  allocated_storage       = var.database.allocated_storage
  max_allocated_storage   = var.database.max_allocated_storage
  multi_az                = var.database.multi_az
  backup_retention_period = var.database.backup_retention_period
  deletion_protection     = var.database.deletion_protection
  skip_final_snapshot     = var.database.skip_final_snapshot
  publicly_accessible     = var.database.publicly_accessible
  credentials_secret_path = var.database.credentials_secret_path

  tags = local.common_tags
}

module "database_peering" {
  count = var.create_database ? 1 : 0

  source = "../../modules/vpc/vpc-peering"

  name                      = "${local.name_prefix}-${var.service_name}-datastore"
  requester_vpc_id          = data.terraform_remote_state.platform.outputs.vpc_id
  accepter_vpc_id           = module.database_vpc[0].vpc_id
  requester_route_table_ids = data.terraform_remote_state.platform.outputs.private_route_table_ids
  accepter_route_table_ids  = [module.database_vpc[0].private_route_table_id]
  requester_cidr_block      = data.terraform_remote_state.platform.outputs.vpc_cidr_block
  accepter_cidr_block       = var.database.vpc_cidr

  tags = local.common_tags
}

module "datastore_peering" {
  count = var.enable_database_peering && !var.create_database ? 1 : 0

  source = "../../modules/vpc/vpc-peering"

  name                      = "${local.name_prefix}-${var.service_name}-datastore"
  requester_vpc_id          = data.terraform_remote_state.platform.outputs.vpc_id
  accepter_vpc_id           = data.terraform_remote_state.datastore[0].outputs.vpc_id
  requester_route_table_ids = data.terraform_remote_state.platform.outputs.private_route_table_ids
  accepter_route_table_ids  = [data.terraform_remote_state.datastore[0].outputs.private_route_table_id]
  requester_cidr_block      = data.terraform_remote_state.platform.outputs.vpc_cidr_block
  accepter_cidr_block       = data.terraform_remote_state.datastore[0].outputs.vpc_cidr_block

  tags = local.common_tags
}

resource "aws_security_group_rule" "datastore_from_platform" {
  count = var.enable_database_peering && !var.create_database ? 1 : 0

  type              = "ingress"
  description       = "PostgreSQL from platform VPC"
  from_port         = var.database_port
  to_port           = var.database_port
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.datastore[0].outputs.db_security_group_id
  cidr_blocks       = [data.terraform_remote_state.platform.outputs.vpc_cidr_block]
}

# --- ECR, ECS service, GitHub deploy role ---

module "ecr" {
  source = "../../modules/container/ecr"

  repository_name = local.ecr_repository_name
  tags            = local.common_tags
}

module "ecs_service" {
  source = "../../modules/compute/ecs-service"

  project_name = var.project_name
  environment  = var.environment
  service_name = var.service_name
  aws_region   = var.aws_region

  cluster_arn        = data.terraform_remote_state.platform.outputs.ecs_cluster_arn
  vpc_id             = data.terraform_remote_state.platform.outputs.vpc_id
  subnet_ids         = data.terraform_remote_state.platform.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.platform.outputs.ecs_tasks_security_group_id]
  alb_listener_arn   = data.terraform_remote_state.platform.outputs.internal_alb_listener_arn
  listener_priority  = var.alb_listener_priority
  path_patterns      = var.alb_path_patterns

  container_image   = local.bootstrap_image
  container_port    = var.container_port
  cpu               = var.task_cpu
  memory            = var.task_memory
  desired_count     = var.desired_count
  log_group_name    = data.terraform_remote_state.platform.outputs.ecs_log_group_name
  health_check_path = var.health_check_path

  environment_variables = local.environment_variables
  secrets = {
    for secret in local.container_secrets :
    secret.name => "${secret.secret_arn}:${secret.json_key}::"
  }
  secret_arns = local.secret_arns

  tags = local.common_tags
}

module "github_deploy_role" {
  source = "../../modules/ci/github-deploy-role"

  role_name               = "${local.name_prefix}-${var.service_name}-github-deploy"
  github_repository       = var.github_repository
  github_branches         = var.github_deploy_branches
  oidc_provider_arn       = data.terraform_remote_state.platform.outputs.github_oidc_provider_arn
  ecr_repository_arn      = module.ecr.repository_arn
  ecs_cluster_arn         = data.terraform_remote_state.platform.outputs.ecs_cluster_arn
  ecs_service_name        = module.ecs_service.service_name
  task_execution_role_arn = module.ecs_service.task_execution_role_arn
  task_role_arn           = module.ecs_service.task_role_arn

  tags = local.common_tags
}
