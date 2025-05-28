variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Primary deployment environment"
  type        = string
}


variable "user_lambda_invoke_arn" {
  description = "ARN of the user management Lambda function"
  type        = string
}

variable "image_lambda_invoke_arn" {
  description = "ARN of the image processing Lambda function"
  type        = string
}

variable "data_lambda_invoke_arn" {
  description = "ARN of the data manipulation Lambda function"
  type        = string
}

variable "cache_enabled" {
  description = "Enable API Gateway cache"
  type        = bool
  default     = true
}

variable "cache_size" {
  description = "API Gateway cache size"
  type        = string
  default     = "0.5"
}

variable "cache_ttl" {
  description = "API Gateway cache TTL in seconds"
  type        = number
  default     = 300
}

variable "stage_variables" {
  description = "Variables for each stage"
  type        = map(map(string))
  default     = {
    dev = {
      lambda_alias = "dev"
      log_level    = "INFO"
    }
    test = {
      lambda_alias = "test"
      log_level    = "INFO"
    }
    prod = {
      lambda_alias = "prod"
      log_level    = "ERROR"
    }
  }
}

variable "stages" {
  description = "List of stages to deploy (e.g., dev, test, prod)"
  type        = list(string)
  default     = ["dev", "test", "prod"]
}
