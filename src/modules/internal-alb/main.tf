locals {
  name_prefix = "${var.project_name}-${var.environment}"
  name        = "${local.name_prefix}-${var.name_suffix}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    Layer       = "platform"
    Component   = "internal-alb"
    ManagedBy   = "terraform"
  })
}

resource "aws_lb" "main" {
  name               = local.name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = jsonencode({
        message = "No microservice route matched. Register listener rules per service."
      })
      status_code = "404"
    }
  }

  tags = local.common_tags
}
