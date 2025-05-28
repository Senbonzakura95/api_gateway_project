variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "source_dir" {
  description = "Directory containing the Lambda function code"
  type        = string
}

variable "handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "index.lambda_handler"
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Ajouter ces deux variables
variable "memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 3
}
