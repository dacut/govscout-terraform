terraform {
  required_providers {
    aws = {
      source = "registry.opentofu.org/hashicorp/aws"
    }
  }
}

variable "crawler_repository" {
  description = "The GitHub repository to use for the crawler"
  default     = "https://github.com/dacut/govscout-backend.git"
  type        = string
}

variable "crawler_branch" {
  description = "The branch to use for the crawler"
  default     = "dev"
  type        = string
}

variable "crawler_lambda_function_arn" {
  description = "The ARN of the Lambda function to use for the crawler"
  type        = string
}

data "aws_arn" "crawler_lambda_function" {
  arn = var.crawler_lambda_function_arn
}
