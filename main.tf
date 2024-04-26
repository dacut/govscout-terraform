terraform {
  required_version = ">= 1.6"
  backend "s3" {}

  required_providers {
    aws = {
      source  = "registry.opentofu.org/hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Project     = local.project
      Environment = local.environment
    }
  }
}
