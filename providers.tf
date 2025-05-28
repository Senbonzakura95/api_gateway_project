provider "aws" {
  region = "us-west-2"  # Utilise la région de ton lab
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
