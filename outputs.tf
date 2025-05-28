output "api_gateway_urls" {
  description = "URLs des différents stages de l'API Gateway"
  value       = module.api_gateway.invoke_urls
}

output "api_gateway_stages" {
  description = "Noms des stages déployés"
  value       = module.api_gateway.stage_names
}

output "lambda_functions" {
  description = "ARNs des fonctions Lambda déployées"
  value = {
    user_management  = module.user_lambda.function_arn
    image_processing = module.image_lambda.function_arn
    data_manipulation = module.data_lambda.function_arn
  }
}
