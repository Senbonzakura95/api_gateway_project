variable "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
}

variable "user_lambda_function_name" {
  description = "Name of the user Lambda function"
  type        = string
}

variable "image_lambda_function_name" {
  description = "Name of the image Lambda function"
  type        = string
}

variable "data_lambda_function_name" {
  description = "Name of the data Lambda function"
  type        = string
}
