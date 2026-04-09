# Copy to backend.hcl and set bucket/region from: cd src/bootstrap && terraform output
# Then: terraform init -backend-config=backend.hcl
#
# Do not add dynamodb_table — it is deprecated; locking uses use_lockfile (S3 native).
# Ensure AWS credentials before init (e.g. aws sso login; export AWS_PROFILE=...)

bucket         = "workout-infrastructure-terraform-state"
region         = "us-east-1"
key            = "identity/production/terraform.tfstate"
encrypt        = true
use_lockfile   = true
