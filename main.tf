# API Gateway
module "api_gateway" {
  source = "./modules/api_gateway"

  project_name = var.project_name
  environment  = var.environment
  
  user_lambda_invoke_arn  = module.user_lambda.invoke_arn
  image_lambda_invoke_arn = module.image_lambda.invoke_arn
  data_lambda_invoke_arn  = module.data_lambda.invoke_arn
  
  cache_enabled = var.cache_enabled
  cache_size    = var.cache_size
  cache_ttl     = var.cache_ttl
}

# Lambda functions
module "user_lambda" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-user-management-${var.environment}"
  source_dir    = "${path.module}/lambda/user_management"
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  
  environment_variables = {
    ENVIRONMENT = var.environment
  }
  
  environment = var.environment
  project_name = var.project_name
  api_gateway_execution_arn = module.api_gateway.execution_arn
}

module "image_lambda" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-image-processing-${var.environment}"
  source_dir    = "${path.module}/lambda/image_processing"
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  
  environment_variables = {
    ENVIRONMENT = var.environment
  }
  
  environment = var.environment
  project_name = var.project_name
  api_gateway_execution_arn = module.api_gateway.execution_arn
}

module "data_lambda" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-data-manipulation-${var.environment}"
  source_dir    = "${path.module}/lambda/data_manipulation"
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  
  environment_variables = {
    ENVIRONMENT = var.environment
  }
  
  environment = var.environment
  project_name = var.project_name
  api_gateway_execution_arn = module.api_gateway.execution_arn
}

# CI/CD Pipeline (optionnel - peut être ajouté séparément)
