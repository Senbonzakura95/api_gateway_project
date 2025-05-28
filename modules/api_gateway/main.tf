resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-${var.environment}"
  description = "API Gateway for ${var.project_name} in ${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Users resource and methods
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_method" "users_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization_type = "NONE"
}

resource "aws_api_gateway_integration" "users_get" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.users_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.user_lambda_invoke_arn
}

# Images resource and methods
resource "aws_api_gateway_resource" "images" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "images"
}

resource "aws_api_gateway_method" "images_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.images.id
  http_method   = "POST"
  authorization_type = "NONE"
}

resource "aws_api_gateway_integration" "images_post" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.images.id
  http_method             = aws_api_gateway_method.images_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.image_lambda_invoke_arn
}

# Data resource and methods
resource "aws_api_gateway_resource" "data" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "data"
}

resource "aws_api_gateway_method" "data_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.data.id
  http_method   = "GET"
  authorization_type = "NONE"
}

resource "aws_api_gateway_integration" "data_get" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.data.id
  http_method             = aws_api_gateway_method.data_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.data_lambda_invoke_arn
}

# Deployments and stages
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.users_get,
    aws_api_gateway_integration.images_post,
    aws_api_gateway_integration.data_get
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.users.id,
      aws_api_gateway_resource.images.id,
      aws_api_gateway_resource.data.id,
      aws_api_gateway_method.users_get.id,
      aws_api_gateway_method.images_post.id,
      aws_api_gateway_method.data_get.id,
      aws_api_gateway_integration.users_get.id,
      aws_api_gateway_integration.images_post.id,
      aws_api_gateway_integration.data_get.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.environment

  variables = {
    "env"      = var.environment
    "logLevel" = var.environment == "dev" ? "DEBUG" : var.environment == "test" ? "INFO" : "ERROR"
  }
}

# Cache settings
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
    caching_enabled = var.cache_enabled
    cache_ttl_in_seconds = var.cache_ttl
  }
}
