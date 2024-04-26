module "top" {
  account_id  = local.account_id
  environment = local.environment
  partition   = local.partition
  project     = local.project
  region      = local.region

  source = "./modules/top"
  providers = {
    aws = aws
  }
}
