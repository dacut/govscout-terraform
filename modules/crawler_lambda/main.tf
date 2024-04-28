terraform {
  required_providers {
    aws = {
      source = "registry.opentofu.org/hashicorp/aws"
    }
  }
}

locals {
  lambda_function_name  = "${local.project}${title(local.environment)}Crawler"
  crawler_ecr_image_tag = var.crawler_ecr_image_tag == null ? "base" : var.crawler_ecr_image_tag
}

variable "crawler_ecr_repository_url" {
  type        = string
  description = "The URL of the GovScout Crawler ECR repository"
}

variable "crawler_ecr_image_tag" {
  type        = string
  description = "The tag of the GovScout Crawler ECR image"
  default     = null
}

output "crawler_lambda_function_arn" {
  description = "The ARN of the Lambda function used for the crawler"
  value       = aws_lambda_function.govscout_crawler.arn
}
