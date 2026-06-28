# Network modules

Three modules work together for the **platform + database** topology:

```text
                    vpc-peering
  vpc-platform  <---------------->  vpc-datastore
  (10.10.0.0/16)                    (10.0.0.0/16 per DB)
        |
   ECS, ALB, API GW                  RDS PostgreSQL
```

## vpc-platform

**Was:** `platform-vpc`

Full VPC for the shared **runtime platform**:

- Public subnets (NAT gateways)
- Private subnets (ECS tasks, internal ALB, API Gateway VPC Link)
- Optional VPC endpoints (ECR, CloudWatch Logs, Secrets Manager)

Used by: `src/stack/platform/network/`

## vpc-datastore

**Was:** `vpc`

Minimal **private-only** VPC for a database:

- Private subnets across two AZs (RDS subnet group)
- No NAT, no public subnets, no internet access

Used when `create_database = true` in `src/stack/ecs-service/`.

## vpc-peering

Connects two VPCs and adds routes in both directions:

- **Requester:** platform VPC (ECS tasks reach the database)
- **Accepter:** datastore VPC (return traffic to ECS)

Used by `ecs-service` when a microservice needs RDS in a separate VPC.

RDS security groups allow PostgreSQL from the **platform VPC CIDR** (not from security group IDs across peering).
