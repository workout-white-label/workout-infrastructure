# VPC modules

```text
vpc/
├── vpc-platform/    # shared runtime network (ECS, ALB, API Gateway)
├── vpc-datastore/   # isolated private network for RDS
└── vpc-peering/     # routes between platform and datastore VPCs
```

```text
                    vpc-peering
  vpc-platform  <---------------->  vpc-datastore
  (10.10.0.0/16)                    (10.0.0.0/16 per DB)
        |
   ECS, ALB, API GW                  RDS PostgreSQL
```

## vpc-platform

Full VPC for the shared **runtime platform**:

- Public subnets (NAT gateways)
- Private subnets (ECS tasks, internal ALB, API Gateway VPC Link)
- Optional VPC endpoints (ECR, CloudWatch Logs, Secrets Manager)

Used by: `src/stack/platform/network/`

## vpc-datastore

Minimal **private-only** VPC for a database:

- Private subnets across two AZs (RDS subnet group)
- No NAT, no public subnets, no internet access

Used when `create_database = true` in `src/stack/ecs-service/`.

## vpc-peering

Connects two VPCs and adds routes in both directions:

- **Requester:** platform VPC (ECS tasks reach the database)
- **Accepter:** datastore VPC (return traffic to ECS)

RDS security groups allow PostgreSQL from the **platform VPC CIDR**.
