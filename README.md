# Workout Infrastructure

Terraform-managed infrastructure for the Workout platform (AWS).

## Organization approach

Infrastructure is split into **workspaces (stacks) by layer**, so each deployable unit has its own root configuration and state. This keeps blast radius small and lets us change each layer independently.

### Principles we follow

- **One workspace = one root config + one state** — You run `terraform plan/apply` from one directory per workspace.
- **Split by volatility and responsibility** — Layers that change at different rates or have different owners live in separate workspaces.
- **Reusable building blocks** — Shared logic lives in `src/modules/`; workspaces in `src/stack/` call those modules.

### Current scope

- **Identity (Cognito)** — In use. User authentication and authorization for the platform.
- **Network (VPC)** — Not used yet. We will add a VPC workspace when we need private networking (e.g. Lambdas, ECS, or private APIs).

We start with **one environment: production**. Additional environments (e.g. staging, dev) can be added later as separate workspace instances or tfvars.

## State backend: S3 + DynamoDB

We store Terraform state in **AWS S3** and use **DynamoDB** for locking. Each workspace has its own state file (e.g. `identity/production/terraform.tfstate`).

- **S3** — Holds the state file itself. It gives you durability, versioning (optional), and encryption. Remote state allows the team to run Terraform from different machines and CI without passing a local file around.
- **DynamoDB** — Used for **state locking**. When someone runs `terraform apply`, Terraform writes a lock row in the table. If another run starts, it sees the lock and waits or fails instead of applying in parallel. That prevents two applies from overwriting each other and corrupting state. Without a lock, concurrent applies can leave state and real infrastructure out of sync.

So: **S3 = where state lives; DynamoDB = how we avoid concurrent applies**. The S3 bucket and DynamoDB table are created once via the `src/bootstrap/` stack (see below).

## Repository layout

All Terraform code lives under **`src/`**. The repo root keeps only docs, license, and config (e.g. `.gitignore`, `.tflint.hcl`).

```
workout-infrastructure/
├── README.md                 # This file
├── LICENSE.md
├── .gitignore
├── .tflint.hcl
└── src/
    ├── terraform.tf          # Provider requirements (shared)
    ├── bootstrap/            # One-time: creates S3 bucket + DynamoDB table for state
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── modules/
    │   └── cognito/          # Reusable Cognito (user pool, app client, etc.)
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    └── stack/
        └── identity/        # Identity stack (Cognito only, for now)
            ├── main.tf      # Backend (S3 + DynamoDB), provider, module "cognito"
            ├── variables.tf
            ├── outputs.tf
            └── production.tfvars # Production environment values
```

- **`src/modules/`** — Reusable Terraform modules. They are not stacks; they are used by the roots under `src/stack/`.
- **`src/stack/identity/`** — The **identity** stack. Everything here (and the `cognito` module it uses) belongs to this stack. One state, one `terraform apply` from this directory.

## First-time setup

1. **Create the state bucket and lock table** (once per AWS account/region):
   ```bash
   cd src/bootstrap
   terraform init
   terraform apply
   ```
   Note the outputs: `state_bucket_name`, `lock_table_name`, `aws_region`.

2. **Configure the identity stack backend**  
   In `src/stack/identity/`, copy `backend.example.hcl` to `backend.hcl` and set:
   - `bucket` = bootstrap output `state_bucket_name`
   - `region` = bootstrap output `aws_region`
   - `dynamodb_table` = bootstrap output `lock_table_name`

3. **Configure production variables**  
   Copy `src/stack/identity/production.tfvars.example` to `src/stack/identity/production.tfvars` and adjust (e.g. `project_name`, `aws_region`). `production.tfvars` is gitignored.

4. **Apply the identity stack**:
   ```bash
   cd src/stack/identity
   terraform init -backend-config=backend.hcl
   terraform plan -var-file=production.tfvars
   terraform apply -var-file=production.tfvars
   ```

## For anyone working on this project

1. **Adding or changing Cognito** — Work under `src/stack/identity/`. Use or extend `src/modules/cognito/` as needed.
2. **Running Terraform** — From the stack root, e.g.:
   ```bash
   cd src/stack/identity
   terraform init
   terraform plan -var-file=production.tfvars
   terraform apply -var-file=production.tfvars
   ```
3. **Adding a new stack (e.g. network later)** — Create a new directory under `src/stack/` (e.g. `src/stack/network/`), give it its own `main.tf`, backend config, and state. Do not mix identity and network in the same stack.
4. **Naming** — We use lowercase, descriptive names for workspaces: `identity` (Cognito), and later `network` (VPC) when we add it. Names are chosen by us; they are not inferred by Terraform from resources.

## References

- [Terraform Enterprise Workspaces Best Practices](https://developer.hashicorp.com/terraform/enterprise/workspaces/best-practices) — Basis for our workspace-by-layer approach.
