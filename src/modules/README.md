# Terraform modules

Reusable building blocks grouped by domain. Stacks under `src/stack/` compose these modules.

| Folder | Modules | Purpose |
|--------|---------|---------|
| `vpc/` | vpc-platform, vpc-datastore, vpc-peering | VPCs and connectivity (see `vpc/README.md`) |
| `edge/` | internal-alb, api-gateway | Public entry and internal routing |
| `compute/` | ecs-cluster, ecs-service | Fargate cluster and per-service runtime |
| `container/` | ecr | Container image registry |
| `data/` | rds | PostgreSQL + Secrets Manager credentials |
| `ci/` | github-deploy-role | GitHub Actions OIDC deploy IAM role |
| `identity/` | cognito, lambda | Auth and pre-token Lambda |
| `web/` | static-site | S3 + CloudFront static hosting |
