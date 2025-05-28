variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  default     = "api-gateway-project"
}

variable "environment" {
  description = "Deployment environment"
  default     = "dev"
}

variable "cache_enabled" {
  description = "Enable API Gateway cache"
  type        = bool
  default     = true
}

variable "cache_size" {
  description = "API Gateway cache size"
  default     = "0.5"
}

variable "cache_ttl" {
  description = "API Gateway cache TTL in seconds"
  default     = 300
}
