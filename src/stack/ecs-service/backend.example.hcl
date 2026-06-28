# Copy to backend.hcl (gitignored in app repos — do not commit secrets).
# State is per microservice: ecs-service/<service_name>/production/terraform.tfstate

bucket       = "workout-infrastructure-terraform-state"
region       = "eu-west-1"
key          = "ecs-service/REPLACE_SERVICE_NAME/production/terraform.tfstate"
encrypt      = true
use_lockfile = true
