# user-manager RDS stack

PostgreSQL database for **workout-user-manager**, matching the JPA/Flyway schema in
`users` (`V1__create_users.sql`).

## What this creates

| Resource | Purpose |
|----------|---------|
| `vpc-datastore` | Private VPC (`10.0.0.0/16`) for RDS |
| RDS PostgreSQL 16 | `user_manager` database |
| Secrets Manager | `workout/production/user-manager/database/credentials` with `jdbc_url`, `username`, `password` |

**VPC peering to the platform VPC is not created here.** After this stack is applied,
run the **ecs-service** stack in `workout-user-manager` with
`enable_database_peering = true` and
`datastore_state_key = "rds/user-manager/production/terraform.tfstate"`.

## Prerequisites

- Platform stack applied (`src/stack/platform/`)
- AWS credentials (e.g. `aws sso login`)

## Apply

```bash
cd src/stack/rds/user-manager
cp backend.example.hcl backend.hcl
cp production.tfvars.example production.tfvars

terraform init -backend-config=backend.hcl
terraform plan  -var-file=production.tfvars
terraform apply -var-file=production.tfvars
```

## Schema (application model)

Flyway creates `users` with:

- `id` (UUID PK)
- `cognito_user_id` (unique)
- `tenant_id` (UUID, nullable)
- `email`, `first_name`, `last_name`
- `role` (`SUPER_USER`, `TRAINER`, `TRAINEE`)
- `status` (`ACTIVE`, `INACTIVE`, `DELETED`)
- `created_at`, `updated_at`

Flyway runs on ECS startup (`spring.flyway.enabled=true`).

## Wire ECS

In `workout-user-manager/deploy/ecs-service.tfvars` (already configured):

```hcl
enable_database_peering = true
datastore_state_key     = "rds/user-manager/production/terraform.tfstate"
```

Re-apply ecs-service after RDS exists so peering and security group rules are created.
