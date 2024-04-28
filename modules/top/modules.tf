module "container" {
  account_id                  = var.account_id
  environment                 = var.environment
  partition                   = var.partition
  project                     = var.project
  region                      = var.region
  source                      = "../../modules/container"
  crawler_lambda_function_arn = module.crawler_lambda.crawler_lambda_function_arn
  providers = {
    aws = aws
  }
}

module "crawler_lambda" {
  account_id                 = var.account_id
  crawler_ecr_image_tag      = var.crawler_ecr_image_tag
  crawler_ecr_repository_url = module.container.crawler_ecr_repository_url
  environment                = var.environment
  partition                  = var.partition
  project                    = var.project
  region                     = var.region
  source                     = "../../modules/crawler_lambda"
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
