resource "aws_cloudwatch_log_group" "govscout_lambda_crawler" {
  name              = "${local.environment}/${local.project}/LambdaCrawler"
  retention_in_days = 365
}
