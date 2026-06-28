terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  name        = "${local.name_prefix}-${var.service_name}-db"
  credentials_secret_name = (
    var.credentials_secret_path != ""
    ? var.credentials_secret_path
    : "${var.project_name}/${var.environment}/${var.service_name}/database/credentials"
  )
  common_tags = merge(var.tags, {
    Project      = var.project_name
    Environment  = var.environment
    Service      = var.service_name
    Microservice = var.service_name
    Component    = "database"
    ManagedBy    = "terraform"
  })
}

resource "random_password" "master" {
  length  = 32
  special = false
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name}-subnet-group"
  })
}

resource "aws_security_group" "db" {
  name        = "${local.name}-sg"
  description = "PostgreSQL access for ${var.service_name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []

    content {
      description     = "PostgreSQL from application security groups"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []

    content {
      description = "PostgreSQL from CIDR blocks (e.g. platform VPC via peering)"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-sg"
  })
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = local.credentials_secret_name
  description = "PostgreSQL credentials for ${var.service_name} (${var.environment}). Used by the ${var.service_name} microservice."

  tags = merge(local.common_tags, {
    Name = local.credentials_secret_name
  })
}

resource "aws_db_instance" "main" {
  identifier = local.name

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az

  backup_retention_period   = var.backup_retention_period
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name}-final"

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = merge(local.common_tags, {
    Name = local.name
  })

  lifecycle {
    ignore_changes = [password]
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    project     = var.project_name
    environment = var.environment
    service     = var.service_name
    component   = "database"
    username    = aws_db_instance.main.username
    password    = random_password.master.result
    engine      = "postgres"
    host        = aws_db_instance.main.address
    port        = aws_db_instance.main.port
    dbname      = aws_db_instance.main.db_name
    jdbc_url    = "jdbc:postgresql://${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  })
}
