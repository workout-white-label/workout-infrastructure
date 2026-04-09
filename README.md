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

## State backend: S3 + native locking

We store Terraform state in **AWS S3** and use **S3-native locking** (`use_lockfile` on the backend). Each stack has its own state object (e.g. `identity/production/terraform.tfstate`) and a companion lock object in the same bucket.

- **S3** — Holds the state file and lock metadata. Versioning helps with recovery. Remote state lets the team and CI share one source of truth.
- **Locking** — Terraform’s S3 backend writes a lock file in the bucket so two applies cannot run at once and corrupt state. This replaces the older DynamoDB lock table pattern (deprecated in Terraform).

The state **bucket** is created once via the `src/bootstrap/` stack (see below).

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
    ├── bootstrap/            # One-time: creates S3 bucket for state
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
            ├── main.tf      # backend "s3" {} + provider + module "cognito"
            ├── variables.tf
            ├── outputs.tf
            └── production.tfvars # Production environment values
```

- **`src/modules/`** — Reusable Terraform modules. They are not stacks; they are used by the roots under `src/stack/`.
- **`src/stack/identity/`** — The **identity** stack. Everything here (and the `cognito` module it uses) belongs to this stack. One state, one `terraform apply` from this directory.

## First-time setup

1. **AWS credentials** — Before any `terraform` command that touches AWS (including `init` with the S3 backend), sign in and select a profile, e.g.  
   `aws sso login --profile YOUR_PROFILE` then `export AWS_PROFILE=YOUR_PROFILE`.

2. **Create the state bucket** (once per AWS account/region):
   ```bash
   cd src/bootstrap
   terraform init
   terraform apply
   ```
   Note the outputs: `state_bucket_name`, `aws_region`.

3. **Configure the identity stack backend**  
   In `src/stack/identity/`, copy `backend.example.hcl` to `backend.hcl` and set `bucket` and `region` from bootstrap outputs. The example already sets `key`, `encrypt`, and **`use_lockfile = true`** (S3-native locking).  
   **Do not** add `dynamodb_table` — Terraform deprecates it. If an old `backend.hcl` still has `dynamodb_table`, delete that line (or replace the file from the example), then run `terraform init -reconfigure -backend-config=backend.hcl`.

4. **Configure production variables**  
   Copy `src/stack/identity/production.tfvars.example` to `src/stack/identity/production.tfvars` and adjust (e.g. `project_name`, `aws_region`). `production.tfvars` is gitignored.

5. **Apply the identity stack**:
   ```bash
   cd src/stack/identity
   terraform init -backend-config=backend.hcl
   terraform plan -var-file=production.tfvars
   terraform apply -var-file=production.tfvars
   ```

### Social sign-in (Google, Facebook, Apple, X)

The identity stack defaults to a **single `web` app client** (public, no secret) with localhost callback URLs you should override in `production.tfvars`.

- **Google, Facebook, Apple** — Set `google_idp`, `facebook_idp`, and/or `apple_idp` in `production.tfvars` (see `production.tfvars.example`). In each provider’s developer console, add the Cognito redirect URI:  
  `https://<your-cognito-domain-prefix>.auth.<aws-region>.amazoncognito.com/oauth2/idpresponse`
- **Email/password** — By default **`allow_cognito_native_sign_in` is `true`**, so Cognito username/password works on the Hosted UI until you add federated IdPs. Set `allow_cognito_native_sign_in = false` for **federated-only** once at least one of `google_idp`, `facebook_idp`, `apple_idp`, or `oidc_identity_providers` is configured (otherwise apply will fail the module check).
- **X (Twitter)** — Amazon Cognito user pools do **not** include a native X IdP (supported types are Google, Facebook, Sign in with Apple, Login with Amazon, SAML, and OIDC). To use X, you would need an **OIDC**-capable integration and `oidc_identity_providers` in `production.tfvars`, or a different architecture (e.g. custom broker). See [Social IdPs](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-social-idp.html).

#### Google works in AWS but looks “disabled” in your web app

Terraform only wires **Cognito** (user pool, Google IdP, app client). Your **frontend** decides whether the Google button is shown or enabled. After `apply`, check the following:

1. **Callback / logout URLs must match exactly** — In `production.tfvars`, set `clients.web.callback_urls` and `clients.web.logout_urls` to the **real** URLs your app uses (scheme, host, path, no trailing slash mismatch). The default is `http://localhost:3000/...`. If the app runs on another origin, add it here and `terraform apply` again. Mismatched `redirect_uri` often breaks OAuth; some SDKs then hide or disable social login.

2. **Confirm Cognito** — In AWS Console: Cognito → your user pool → **App integration** → your app client → confirm **Google** is listed under identity providers. Optionally open the Hosted UI:  
   `https://<domain-prefix>.auth.<region>.amazoncognito.com/login?client_id=<web_client_id>&response_type=code&scope=email+openid+profile&redirect_uri=<url-encoded-callback>`  
   If Google works there, Cognito is fine and the issue is app config.

3. **Use Cognito for “Sign in with Google”, not only the Google JS button** — With this setup, sign-in should go through **Cognito’s OAuth / Hosted UI** (or `signInWithRedirect` with provider `Google` in Amplify), using the **Cognito app client id**, not a separate “Sign in with Google” widget that only uses the Google OAuth client without Cognito.

4. **Amplify / env vars** — If you use AWS Amplify Auth, the app needs the OAuth domain, `client_id`, callbacks, and `loginWith.oauth.providers` (or equivalent) including Google; missing config often disables the Google option in the UI.

5. **Google Cloud OAuth consent** — If the OAuth client is in **Testing**, only **test users** can sign in; others can see errors (sometimes surfaced as a dead or disabled control in the app).

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
