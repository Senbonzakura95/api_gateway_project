# Crée d'abord les fonctions Lambda sans la dépendance à l'API Gateway
module "user_lambda" {
  source = "./modules/lambda"

  function_name = "user-management"
  source_dir    = "${path.module}/lambda/user_management"  # Utilise underscore ici
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  
  environment_variables = {
    ENVIRONMENT = var.environment
  }
  
  environment = var.environment
  project_name = var.project_name
  memory_size  = 128
  timeout      = 3
}

module "image_lambda" {
  source = "./modules/lambda"

  function_name = "image-processing"
  source_dir    = "${path.module}/lambda/image_processing"  # Utilise underscore ici
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  
  environment_variables = {
    ENVIRONMENT = var.environment
  }
  
  environment = var.environment
  project_name = var.project_name
  memory_size  = 256
  timeout      = 10
}

module "data_lambda" {
  source = "./modules/lambda"

  function_name = "data-manipulation"
  source_dir    = "${path.module}/lambda/data_manipulation"  # Utilise underscore ici
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  
  environment_variables = {
    ENVIRONMENT = var.environment
  }
  
  environment = var.environment
  project_name = var.project_name
  memory_size  = 128
  timeout      = 5
}

# Ensuite, crée l'API Gateway qui dépend des Lambda
module "api_gateway" {
  source = "./modules/api_gateway"

  project_name = var.project_name
  environment  = var.environment
  stages       = ["dev", "test", "prod"]  # Définir les stages à déployer
  
  user_lambda_invoke_arn  = module.user_lambda.invoke_arn
  image_lambda_invoke_arn = module.image_lambda.invoke_arn
  data_lambda_invoke_arn  = module.data_lambda.invoke_arn
  
  cache_enabled = var.cache_enabled
  cache_size    = var.cache_size
  cache_ttl     = var.cache_ttl
}


# Enfin, ajoute les permissions Lambda pour API Gateway
module "lambda_permissions" {
  source = "./modules/lambda_permissions"
  
  depends_on = [module.api_gateway, module.user_lambda, module.image_lambda, module.data_lambda]
  
  api_gateway_execution_arn = module.api_gateway.execution_arn
  user_lambda_function_name = module.user_lambda.function_name
  image_lambda_function_name = module.image_lambda.function_name
  data_lambda_function_name = module.data_lambda.function_name
}
