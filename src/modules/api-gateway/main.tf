locals {
  name_prefix = "${var.project_name}-${var.environment}"
  name        = "${local.name_prefix}-${var.name_suffix}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    Layer       = "platform"
    Component   = "api-gateway"
    ManagedBy   = "terraform"
  })
}

resource "aws_apigatewayv2_vpc_link" "main" {
  name               = "${local.name}-vpc-link"
  security_group_ids = var.vpc_link_security_group_ids
  subnet_ids         = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name}-vpc-link"
  })
}

resource "aws_apigatewayv2_api" "main" {
  name          = local.name
  protocol_type = "HTTP"
  description   = "Public entry point for Workout microservices via internal ALB."

  cors_configuration {
    allow_headers = ["authorization", "content-type", "x-request-id"]
    allow_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    allow_origins = var.cors_allow_origins
    max_age       = 300
  }

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

resource "aws_apigatewayv2_integration" "alb" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = var.alb_listener_arn
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.main.id

  request_parameters = {
    "overwrite:path" = "$request.path.proxy"
  }

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_integration" "alb_root" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = var.alb_listener_arn
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.main.id

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.alb_root.id}"
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.environment
  auto_deploy = true

  tags = merge(local.common_tags, {
    Name = "${local.name}-${var.environment}"
  })
}
