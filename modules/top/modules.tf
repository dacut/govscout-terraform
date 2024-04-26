module "container" {
  account_id  = var.account_id
  environment = var.environment
  partition   = var.partition
  project     = var.project
  region      = var.region
  source      = "../../modules/container"
  providers = {
    aws = aws
  }
}

module "lambda" {
  account_id         = var.account_id
  ecr_image_tag      = var.ecr_image_tag
  ecr_repository_url = module.container.ecr_repository_url
  environment        = var.environment
  partition          = var.partition
  project            = var.project
  region             = var.region
  source             = "../../modules/lambda"
  providers = {
    aws = aws
  }
}

terraform {
  required_providers {
    aws = {
      source = "registry.opentofu.org/hashicorp/aws"
    }
  }
}
