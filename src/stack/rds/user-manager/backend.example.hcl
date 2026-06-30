# Copy to backend.hcl (gitignored) before terraform init.
#
#   cd src/stack/rds/user-manager
#   cp backend.example.hcl backend.hcl
#   terraform init -backend-config=backend.hcl
#   terraform apply -var-file=production.tfvars

bucket       = "workout-infrastructure-terraform-state"
region       = "eu-west-1"
key          = "rds/user-manager/production/terraform.tfstate"
encrypt      = true
use_lockfile = true
