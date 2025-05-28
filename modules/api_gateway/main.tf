resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-api"
  description = "API Gateway for ${var.project_name}"

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
  authorization = "NONE"
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
  authorization = "NONE"
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
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "data_get" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.data.id
  http_method             = aws_api_gateway_method.data_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.data_lambda_invoke_arn
}

# Deployment - une seule version de l'API
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.users_get,
    aws_api_gateway_integration.images_post,
    aws_api_gateway_integration.data_get
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  description = "Deployment for ${var.project_name}"
  
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

# Créer plusieurs stages (dev, test, prod)
resource "aws_api_gateway_stage" "stages" {
  for_each = toset(var.stages)
  
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = each.value
  
  variables = {
    "env"      = each.value
    "logLevel" = each.value == "dev" ? "DEBUG" : each.value == "test" ? "INFO" : "ERROR"
  }
  
  # Activer la mise en cache uniquement pour prod et test
  cache_cluster_enabled = var.cache_enabled && (each.value == "prod" || each.value == "test")
  cache_cluster_size    = var.cache_size
  
  # Ajouter des tags spécifiques à chaque environnement
  tags = {
    Environment = each.value
    Project     = var.project_name
  }
}

# Configurer les paramètres de méthode pour chaque stage
resource "aws_api_gateway_method_settings" "settings" {
  for_each = toset(var.stages)
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stages[each.value].stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "OFF"  # Désactivé pour éviter les problèmes de permissions
    
    # Activer la mise en cache uniquement pour prod et test
    caching_enabled = var.cache_enabled && (each.value == "prod" || each.value == "test")
    cache_ttl_in_seconds = var.cache_ttl
    
    # Paramètres supplémentaires spécifiques à chaque environnement
    throttling_burst_limit = each.value == "prod" ? 5000 : 2000
    throttling_rate_limit  = each.value == "prod" ? 10000 : 1000
  }
}

# Documentation API (optionnel)
resource "aws_api_gateway_documentation_part" "api_info" {
  location {
    type = "API"
  }
  
  properties = jsonencode({
    info = {
      description = "API for ${var.project_name}"
      version     = "1.0.0"
    }
  })
  
  rest_api_id = aws_api_gateway_rest_api.api.id
}

# Ajouter des clés d'API pour limiter l'accès (optionnel)
resource "aws_api_gateway_api_key" "api_key" {
  for_each = toset(var.stages)
  
  name = "${var.project_name}-${each.value}-key"
  description = "API Key for ${var.project_name} ${each.value} environment"
  enabled = true
}

# Créer un plan d'utilisation pour chaque environnement (optionnel)
resource "aws_api_gateway_usage_plan" "usage_plan" {
  for_each = toset(var.stages)
  
  name         = "${var.project_name}-${each.value}-plan"
  description  = "Usage plan for ${var.project_name} ${each.value} environment"
  
  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.stages[each.value].stage_name
  }
  
  quota_settings {
    limit  = each.value == "prod" ? 10000 : 1000
    period = "DAY"
  }
  
  throttle_settings {
    burst_limit = each.value == "prod" ? 5000 : 2000
    rate_limit  = each.value == "prod" ? 10000 : 1000
  }
}

# Associer les clés d'API aux plans d'utilisation (optionnel)
resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  for_each = toset(var.stages)
  
  key_id        = aws_api_gateway_api_key.api_key[each.value].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan[each.value].id
}
