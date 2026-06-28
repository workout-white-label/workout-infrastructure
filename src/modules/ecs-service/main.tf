locals {
  name_prefix = "${var.project_name}-${var.environment}"
  name        = "${local.name_prefix}-${var.service_name}"
  common_tags = merge(var.tags, {
    Project      = var.project_name
    Environment  = var.environment
    Microservice = var.service_name
    ManagedBy    = "terraform"
  })

  container_environment = [
    for key, value in var.environment_variables : {
      name  = key
      value = value
    }
  ]

  container_secrets = [
    for key, value_from in var.secrets : {
      name      = key
      valueFrom = value_from
    }
  ]
}

resource "aws_lb_target_group" "main" {
  name_prefix = substr("${var.service_name}-", 0, 6)
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
    protocol            = "HTTP"
  }

  deregistration_delay = 30

  tags = merge(local.common_tags, {
    Name      = "${local.name}-tg"
    Component = "ecs-target-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.alb_listener_arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = var.path_patterns
    }
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name}-listener-rule"
    Component = "alb-listener-rule"
  })
}

resource "aws_iam_role" "task_execution" {
  name = "${local.name}-ecs-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "task_execution_secrets" {
  count = length(var.secret_arns) > 0 ? 1 : 0

  name = "${local.name}-secrets-read"
  role = aws_iam_role.task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secret_arns
      }
    ]
  })
}

resource "aws_iam_role" "task" {
  name = "${local.name}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_ecs_task_definition" "main" {
  family                   = local.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = local.container_environment
      secrets     = local.container_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.service_name
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = merge(local.common_tags, {
    Name      = local.name
    Component = "ecs-task-definition"
  })
}

resource "aws_ecs_service" "main" {
  name            = local.name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  tags = merge(local.common_tags, {
    Name      = local.name
    Component = "ecs-service"
  })

  depends_on = [aws_lb_listener_rule.main]

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}
