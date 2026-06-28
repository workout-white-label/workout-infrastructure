# ECS service stack (per microservice)

Apply this stack from each microservice repository via a **git submodule** of
`workout-infrastructure`. Git submodules clone the full repository; run Terraform
from this directory inside the submodule.

## 1. Add submodule (once per app repo)

From the microservice repository root:

```bash
git submodule add https://github.com/workout-white-label/workout-infrastructure.git infrastructure
git submodule update --init --recursive
```

Pin a tag or commit for reproducibility:

```bash
cd infrastructure
git checkout v1.0.0   # or a specific commit
cd ..
git add infrastructure .gitmodules
git commit -m "Add infrastructure submodule"
```

## 2. Service config (in the app repo, not in the submodule)

Keep `backend.hcl` and `production.tfvars` **outside** the submodule so they are
not overwritten on submodule updates:

```text
workout-user-manager/
├── infrastructure/                    # submodule → workout-infrastructure
├── deploy/
│   ├── ecs-service.backend.hcl
│   └── ecs-service.tfvars
└── .github/workflows/                 # build, test, ECR, ECS deploy
```

Copy examples:

```bash
cp infrastructure/src/stack/ecs-service/backend.example.hcl deploy/ecs-service.backend.hcl
cp infrastructure/src/stack/ecs-service/production.tfvars.example deploy/ecs-service.tfvars
# Edit deploy/ecs-service.tfvars and set service_name, github_repository, paths, etc.
# Edit deploy/ecs-service.backend.hcl key → ecs-service/<service_name>/production/terraform.tfstate
```

## 3. Apply

Prerequisite: `platform` stack applied in the same AWS account/region.

```bash
cd infrastructure/src/stack/ecs-service

terraform init -backend-config=../../../../deploy/ecs-service.backend.hcl
terraform plan  -var-file=../../../../deploy/ecs-service.tfvars
terraform apply -var-file=../../../../deploy/ecs-service.tfvars
```

## 4. Wire GitHub Actions

Use `terraform output` from this directory:

| Output | GitHub variable |
|--------|-----------------|
| `github_deploy_role_arn` | `AWS_ROLE_ARN` |
| `ecr_repository_url` | `ECR_REPOSITORY` |
| `ecs_cluster_name` | `ECS_CLUSTER` |
| `service_name` | `ECS_SERVICE` |
| `container_name` | `ECS_CONTAINER_NAME` |

## 5. Update submodule

When infrastructure modules change:

```bash
cd infrastructure
git fetch
git checkout <new-tag-or-commit>
cd ../..
git add infrastructure
git commit -m "Bump infrastructure submodule"
```
