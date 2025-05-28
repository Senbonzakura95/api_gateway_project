variable "function_name" {
  description = "Name of the Lambda function"
}

variable "source_dir" {
  description = "Directory containing Lambda function code"
}

variable "handler" {
  description = "Lambda function handler"
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime"
  default     = "python3.9"
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  default     = 30
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Deployment environment"
}

variable "project_name" {
  description = "Name of the project"
}

variable "api_gateway_execution_arn" {
  description = "API Gateway execution ARN"
}
