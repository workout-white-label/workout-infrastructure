# Platform root — shared runtime (network, edge, compute cluster, CI OIDC).
# Per-microservice deploy: src/stack/ecs-service (git submodule in each app repo).

module "network" {
  source = "./network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  enable_vpc_endpoints = var.enable_vpc_endpoints
  tags                 = local.common_tags
}

module "ci" {
  source = "./ci"

  project_name                              = var.project_name
  environment                               = var.environment
  manage_github_oidc_provider             = var.manage_github_oidc_provider
  terraform_state_bucket                    = var.terraform_state_bucket
  aws_region                                = var.aws_region
  github_ecs_service_terraform_repositories = var.github_ecs_service_terraform_repositories
  tags                                      = local.common_tags
}

module "edge" {
  source = "./edge"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  vpc_cidr_block     = module.network.vpc_cidr_block
  private_subnet_ids = module.network.private_subnet_ids
  alb_listener_port  = var.alb_listener_port
  cors_allow_origins = var.cors_allow_origins
  tags               = local.common_tags

  depends_on = [module.network]
}

module "compute" {
  source = "./compute"

  project_name              = var.project_name
  environment               = var.environment
  enable_container_insights = var.enable_container_insights
  tags                      = local.common_tags

  depends_on = [module.network]
}

module "bastion" {
  count  = var.enable_ssm_bastion ? 1 : 0
  source = "./bastion"

  project_name                = var.project_name
  environment                 = var.environment
  vpc_id                      = module.network.vpc_id
  subnet_id                   = module.network.private_subnet_ids[0]
  instance_type               = var.ssm_bastion_instance_type
  postgres_egress_cidr_blocks = var.ssm_bastion_postgres_egress_cidr_blocks
  tags                        = local.common_tags

  depends_on = [module.network]
}
