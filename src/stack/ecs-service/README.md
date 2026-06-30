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

Run these commands from the **microservice repository root** (e.g. `workout-user-manager`),
not from `workout-infrastructure` directly. The `deploy/` folder with `ecs-service.backend.hcl`
lives in the app repo; the relative path below only resolves there.

```bash
cd infrastructure/src/stack/ecs-service

terraform init -backend-config=../../../../deploy/ecs-service.backend.hcl
terraform plan  -var-file=../../../../deploy/ecs-service.tfvars
terraform apply -var-file=../../../../deploy/ecs-service.tfvars
```

## 4. Wire GitHub Actions

**ecs-service Terraform runs in CI** (`terraform-ecs-service.yml` in the app repo).
After `terraform apply`, outputs are passed to ECR and ECS deploy jobs — no manual
deploy variables required.

One repository variable is needed before the first pipeline run:

| Platform output | GitHub variable |
|-----------------|-----------------|
| `github_ecs_service_terraform_role_arn` | `TERRAFORM_AWS_ROLE_ARN` |

Add the app repo to `github_ecs_service_terraform_repositories` in the platform
stack `production.tfvars`, apply platform, then set the variable above.

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
