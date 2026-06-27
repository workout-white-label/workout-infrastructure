# Copy to backend.hcl and set bucket/region from: cd src/bootstrap && terraform output
# Then: terraform init -backend-config=backend.hcl

bucket       = "workout-infrastructure-terraform-state"
region       = "eu-west-1"
key          = "rds/user-manager/production/terraform.tfstate"
encrypt      = true
use_lockfile = true
