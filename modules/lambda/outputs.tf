output "invoke_arn" {
  description = "The ARN to be used for invoking Lambda Function from API Gateway"
  value       = aws_lambda_function.lambda.invoke_arn
}

output "function_name" {
  description = "The name of the Lambda Function"
  value       = aws_lambda_function.lambda.function_name
}

output "function_arn" {
  description = "The ARN of the Lambda Function"
  value       = aws_lambda_function.lambda.arn
}
