# Copy to backend.hcl and fill with outputs from: cd src/bootstrap && terraform output
# Then: terraform init -backend-config=backend.hcl

bucket         = "workout-infrastructure-terraform-state"
region         = "us-east-1"
dynamodb_table = "workout-infrastructure-terraform-locks"
