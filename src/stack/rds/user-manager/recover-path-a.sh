#!/usr/bin/env bash
# Path A: destroy RDS stack in us-east-1, then redeploy in eu-west-1.
#
# Prerequisites:
#   aws sso login --profile YOUR_PROFILE
#   export AWS_PROFILE=YOUR_PROFILE
#
# Usage (from this directory):
#   chmod +x recover-path-a.sh
#   ./recover-path-a.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [[ ! -f backend.hcl ]]; then
  echo "Copy backend.example.hcl to backend.hcl first."
  exit 1
fi

echo "==> Reconfigure backend"
terraform init -reconfigure -backend-config=backend.hcl

echo "==> Step 1: Point provider at us-east-1 and disable RDS deletion protection (if instance exists)"
terraform apply -var-file=production.destroy-us-east-1.tfvars

echo "==> Step 2: Destroy all resources in us-east-1"
terraform destroy -var-file=production.destroy-us-east-1.tfvars

echo "==> Step 3: Fresh deploy in eu-west-1"
terraform apply -var-file=production.tfvars

echo "==> Done. Database is in eu-west-1."
