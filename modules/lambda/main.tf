terraform {
  required_providers {
    aws = {
      source = "registry.opentofu.org/hashicorp/aws"
    }
  }
}

locals {
  lambda_function_name = "${local.project}${title(local.environment)}Crawler"
}
