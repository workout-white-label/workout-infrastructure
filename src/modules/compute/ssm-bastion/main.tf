locals {
  name_prefix = "${var.project_name}-${var.environment}"
  name        = "${local.name_prefix}-ssm-bastion"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    Component   = "ssm-bastion"
    ManagedBy   = "terraform"
  })
}

data "aws_ssm_parameter" "amazon_linux_2023_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_iam_role" "bastion" {
  name = "${local.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.name}-profile"
  role = aws_iam_role.bastion.name

  tags = local.common_tags
}

resource "aws_security_group" "bastion" {
  name        = "${local.name}-sg"
  description = "SSM bastion — no inbound; egress for SSM and PostgreSQL"
  vpc_id      = var.vpc_id

  egress {
    description = "HTTPS for SSM and AWS APIs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "PostgreSQL to datastore VPC(s)"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.postgres_egress_cidr_blocks
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-sg"
  })
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023_arm64.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = local.name
  })
}
