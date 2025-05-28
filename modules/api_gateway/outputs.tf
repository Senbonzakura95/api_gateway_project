output "api_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "execution_arn" {
  description = "The execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "invoke_urls" {
  description = "The URLs to invoke the API Gateway stages"
  value = {
    for stage_name in var.stages :
    stage_name => "${aws_api_gateway_deployment.deployment.invoke_url}${stage_name}"
  }
}

output "stage_names" {
  description = "The names of the deployed stages"
  value       = var.stages
}
